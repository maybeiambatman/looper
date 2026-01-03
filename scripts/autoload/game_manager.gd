## Main game manager that controls game state and flow
extends Node

# Signals
signal hole_started(hole_number: int)
signal hole_completed(hole_number: int, score: int)
signal shot_started(recommendation: ShotRecommendation)
signal shot_completed(outcome: ShotOutcome)
signal run_started()
signal run_completed(won: bool)
signal leaderboard_updated()
signal score_changed(player_score: int, leader_score: int)
signal pressure_changed(pressure_level: Enums.PressureLevel)

# Constants
const HOLES_PER_RUN := 5
const STARTING_HOLE := 14  # Holes 14-18

# Current state
var current_run: RunData = null
var tournament: TournamentState = null
var player: GolferAttributes = null
var current_hole_data: HoleData = null
var current_conditions: HoleConditions = null
var active_trinkets: Array = []
var meta_progress: MetaProgression = null

# Ball state
var ball_position: Vector3 = Vector3.ZERO
var current_lie: Enums.LieType = Enums.LieType.TEE
var strokes_this_hole: int = 0
var is_on_green: bool = false

# Game state flags
var is_in_run: bool = false
var is_hole_active: bool = false
var mulligan_available: bool = false


func _ready() -> void:
	# Load meta progression
	meta_progress = SaveManager.load_meta_progress()
	print("Loaded meta progress: Level %d, %d XP" % [meta_progress.caddie_level, meta_progress.total_xp])


func start_new_run(difficulty: int = 1) -> void:
	"""Begin a new roguelite run"""
	current_run = RunData.new()
	current_run.difficulty = difficulty
	current_run.run_number = meta_progress.total_runs + 1
	current_run.timestamp = Time.get_unix_time_from_system()

	# Generate player
	var use_veteran := meta_progress.has_upgrade("veteran_players") and randf() > 0.5
	if use_veteran:
		player = GolferGenerator.generate_veteran_player()
	else:
		player = GolferGenerator.generate_player(difficulty, active_trinkets)

	# Apply player trinkets
	for trinket in active_trinkets:
		if trinket and trinket.is_player_trinket():
			trinket.apply_to_player(player)

	# Setup tournament state
	tournament = TournamentState.new()
	tournament.leader_name = GolferGenerator._generate_name()
	tournament.leader_attributes = GolferGenerator.generate_leader(difficulty)

	# Starting scores based on difficulty
	tournament.leader_score = -10 - difficulty
	tournament.player_score = tournament.leader_score + difficulty  # 1-4 back
	tournament.holes_remaining = HOLES_PER_RUN

	# Generate holes for this run
	current_run.holes = HoleGenerator.generate_run(difficulty, active_trinkets)

	# Check for mulligan trinket
	mulligan_available = TrinketManager.has_trinket_effect(active_trinkets, Enums.TrinketEffectType.MULLIGAN)

	is_in_run = true
	run_started.emit()

	# Start first hole
	start_hole(0)


func continue_run() -> bool:
	"""Continue a saved run, returns false if no save exists"""
	var save_data := SaveManager.load_run()
	if save_data.is_empty():
		return false

	current_run = save_data.get("run_data")
	player = save_data.get("player")
	tournament = save_data.get("tournament")
	active_trinkets = save_data.get("trinkets", [])

	# Regenerate holes (they're procedural anyway)
	current_run.holes = HoleGenerator.generate_run(current_run.difficulty, active_trinkets)

	mulligan_available = TrinketManager.has_trinket_effect(active_trinkets, Enums.TrinketEffectType.MULLIGAN)
	is_in_run = true
	run_started.emit()

	# Continue from current hole
	start_hole(current_run.current_hole)
	return true


func start_hole(hole_index: int) -> void:
	"""Begin playing a hole"""
	current_run.current_hole = hole_index
	current_hole_data = current_run.holes[hole_index] if hole_index < current_run.holes.size() else null

	if not current_hole_data:
		push_error("No hole data for index %d" % hole_index)
		return

	# Generate conditions for this hole
	current_conditions = HoleConditions.generate_random(current_run.difficulty)

	# Apply favorable conditions trinket
	if TrinketManager.has_trinket_effect(active_trinkets, Enums.TrinketEffectType.FAVORABLE_CONDITIONS):
		current_conditions.wind_speed *= 0.7
		current_conditions.green_firmness = "Medium"

	# Reset hole state
	strokes_this_hole = 0
	ball_position = current_hole_data.tee_position
	current_lie = Enums.LieType.TEE
	is_on_green = false
	is_hole_active = true

	# Update pressure
	tournament.update_pressure()
	pressure_changed.emit(tournament.current_pressure)

	hole_started.emit(hole_index + STARTING_HOLE)

	# Save progress
	_save_current_state()


func execute_shot(recommendation: ShotRecommendation) -> ShotOutcome:
	"""Execute a shot and return the outcome"""
	shot_started.emit(recommendation)

	# Calculate outcome
	var outcome := ShotCalculator.calculate_shot(
		recommendation,
		player,
		current_conditions,
		current_lie,
		active_trinkets,
		tournament
	)

	# Apply outcome
	strokes_this_hole += 1
	current_run.shots_taken += 1
	ball_position = outcome.final_position
	current_lie = outcome.resulting_lie
	is_on_green = current_lie == Enums.LieType.GREEN

	# Track decision quality
	if outcome.result in [Enums.ShotResult.PERFECT, Enums.ShotResult.GOOD]:
		current_run.good_decisions += 1
	elif outcome.result == Enums.ShotResult.DISASTER:
		current_run.bad_decisions += 1

	# Generate description
	outcome.generate_description(recommendation.shot_type == Enums.ShotType.PUTT)

	shot_completed.emit(outcome)

	# Check if holed out
	if outcome.made_putt:
		complete_hole()

	return outcome


func use_mulligan() -> bool:
	"""Use the mulligan if available"""
	if mulligan_available:
		mulligan_available = false
		strokes_this_hole -= 1
		current_run.shots_taken -= 1
		return true
	return false


func complete_hole() -> void:
	"""Finish the current hole"""
	var score := strokes_this_hole - current_hole_data.par
	current_run.hole_scores.append(score)

	# Update tournament state
	tournament.record_player_hole(score)

	# Simulate leader's hole
	var leader_score := LeaderAI.simulate_hole(
		current_hole_data,
		current_conditions,
		tournament.leader_attributes,
		tournament,
		active_trinkets
	)
	tournament.record_leader_hole(leader_score)

	is_hole_active = false
	hole_completed.emit(current_run.current_hole + STARTING_HOLE, score)
	score_changed.emit(tournament.player_score, tournament.leader_score)
	leaderboard_updated.emit()

	# Check if run is complete
	if tournament.is_tournament_over():
		complete_run()
	else:
		# Save and prepare for next hole
		_save_current_state()


func complete_run() -> void:
	"""End the current run"""
	var won := tournament.did_player_win()
	current_run.won = won
	is_in_run = false

	# Calculate XP
	var xp_earned := _calculate_run_xp()
	var levels_gained := meta_progress.add_xp(xp_earned)

	# Update stats
	if won:
		meta_progress.wins += 1
		if current_run.run_number > meta_progress.highest_run:
			meta_progress.highest_run = current_run.run_number
	else:
		meta_progress.losses += 1

	meta_progress.total_runs += 1

	# Record statistics
	meta_progress.record_statistic("total_shots", current_run.shots_taken)
	meta_progress.record_statistic("good_decisions", current_run.good_decisions)

	# Save meta progress
	SaveManager.save_meta_progress(meta_progress)

	# Delete run save
	SaveManager.delete_run_save()

	run_completed.emit(won)


func _calculate_run_xp() -> int:
	var xp := 0
	xp += current_run.shots_taken * 5  # Base XP per shot
	xp += current_run.good_decisions * 20  # Bonus for good decisions
	xp -= current_run.bad_decisions * 5  # Small penalty for bad decisions

	if current_run.won:
		xp += 200  # Win bonus
		xp += current_run.difficulty * 50  # Difficulty bonus

	return maxi(0, xp)


func _save_current_state() -> void:
	if current_run and player and tournament:
		SaveManager.save_run(current_run, player, tournament)


func add_trinket(trinket: Trinket) -> void:
	"""Add a trinket to the active set"""
	active_trinkets.append(trinket)

	# Apply immediate effects
	if trinket.is_player_trinket():
		trinket.apply_to_player(player)

	if trinket.effect_type == Enums.TrinketEffectType.MULLIGAN:
		mulligan_available = true


func get_current_hole_number() -> int:
	return current_run.current_hole + STARTING_HOLE if current_run else 14


func get_distance_to_pin() -> float:
	if not current_hole_data:
		return 0.0
	return ball_position.distance_to(current_hole_data.pin_position)


func get_yardage_to_pin() -> int:
	return int(get_distance_to_pin() * 1.09361)  # Convert meters to yards


func is_ball_on_green() -> bool:
	return is_on_green


func get_suggested_club() -> String:
	var distance := get_yardage_to_pin()
	return player.get_best_club_for_distance(distance) if player else "7_iron"
