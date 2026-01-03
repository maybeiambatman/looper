## Simulates the tournament leader's performance
class_name LeaderAI
extends RefCounted


static func simulate_hole(
	hole_data: HoleData,
	conditions: HoleConditions,
	leader: GolferAttributes,
	tournament: TournamentState,
	trinkets: Array
) -> int:
	"""
	Simulates the leader playing a hole and returns their score relative to par.
	Returns: -1 for birdie, 0 for par, +1 for bogey, etc.
	"""

	# Base scoring probability based on leader skill
	var skill_avg := leader.get_average_rating()
	var difficulty_modifier := _get_hole_difficulty_modifier(hole_data, conditions)

	# Check for Leader's Curse trinket
	var has_curse := TrinketManager.has_trinket_effect(trinkets, Enums.TrinketEffectType.LEADER_PRESSURE)

	# Calculate pressure on leader
	var pressure_penalty := _calculate_leader_pressure(tournament, leader, has_curse)

	# Base probabilities for each outcome
	var birdie_chance := 0.0
	var par_chance := 0.0
	var bogey_chance := 0.0
	var double_chance := 0.0

	match hole_data.par:
		3:
			birdie_chance = 15.0 + (skill_avg - 12) * 2.0
			par_chance = 55.0 + (skill_avg - 12) * 1.5
			bogey_chance = 25.0 - (skill_avg - 12) * 1.0
			double_chance = 5.0 - (skill_avg - 12) * 0.5
		4:
			birdie_chance = 12.0 + (skill_avg - 12) * 2.0
			par_chance = 58.0 + (skill_avg - 12) * 1.5
			bogey_chance = 25.0 - (skill_avg - 12) * 1.0
			double_chance = 5.0 - (skill_avg - 12) * 0.5
		5:
			birdie_chance = 25.0 + (skill_avg - 12) * 2.5  # More birdie chances on par 5s
			par_chance = 50.0 + (skill_avg - 12) * 1.0
			bogey_chance = 20.0 - (skill_avg - 12) * 1.0
			double_chance = 5.0 - (skill_avg - 12) * 0.5

	# Apply difficulty modifier
	birdie_chance -= difficulty_modifier * 3.0
	par_chance -= difficulty_modifier * 2.0
	bogey_chance += difficulty_modifier * 3.0
	double_chance += difficulty_modifier * 2.0

	# Apply pressure penalty
	birdie_chance -= pressure_penalty * 2.0
	par_chance -= pressure_penalty * 1.0
	bogey_chance += pressure_penalty * 2.0
	double_chance += pressure_penalty * 1.0

	# Clamp probabilities
	birdie_chance = clampf(birdie_chance, 2.0, 40.0)
	par_chance = clampf(par_chance, 30.0, 70.0)
	bogey_chance = clampf(bogey_chance, 5.0, 40.0)
	double_chance = clampf(double_chance, 1.0, 15.0)

	# Normalize to 100%
	var total := birdie_chance + par_chance + bogey_chance + double_chance
	birdie_chance = birdie_chance / total * 100.0
	par_chance = par_chance / total * 100.0
	bogey_chance = bogey_chance / total * 100.0
	double_chance = double_chance / total * 100.0

	# Roll for result
	var roll := randf() * 100.0

	if roll < birdie_chance:
		# Small chance of eagle on par 5
		if hole_data.par == 5 and randf() < 0.1:
			return -2  # Eagle
		return -1  # Birdie
	elif roll < birdie_chance + par_chance:
		return 0  # Par
	elif roll < birdie_chance + par_chance + bogey_chance:
		return 1  # Bogey
	else:
		# Small chance of triple on disasters
		if randf() < 0.15:
			return 3  # Triple
		return 2  # Double bogey


static func _get_hole_difficulty_modifier(hole_data: HoleData, conditions: HoleConditions) -> float:
	"""Calculate how difficult this hole is"""
	var difficulty := 0.0

	# Water hazards add difficulty
	if hole_data.has_water:
		difficulty += 2.0

	# Wind adds difficulty
	if conditions.wind_speed > 15:
		difficulty += 2.0
	elif conditions.wind_speed > 10:
		difficulty += 1.0

	# Fast greens add difficulty
	if conditions.green_speed == "Lightning":
		difficulty += 1.5
	elif conditions.green_speed == "Fast":
		difficulty += 0.5

	# Firm greens add difficulty for approach-heavy holes
	if conditions.green_firmness == "Firm" and hole_data.par != 5:
		difficulty += 1.0

	return difficulty


static func _calculate_leader_pressure(tournament: TournamentState, leader: GolferAttributes, has_curse: bool) -> float:
	"""Calculate pressure on the leader"""
	var base_pressure := 0.0

	# Leader feels more pressure when lead is small or they're chasing
	var deficit := tournament.get_deficit()

	if deficit <= 0:
		# Leader is ahead or tied
		if deficit == 0:
			base_pressure = 2.0  # Tied feels pressure
		elif deficit >= -1:
			base_pressure = 1.5  # Small lead
		elif deficit >= -2:
			base_pressure = 1.0  # Comfortable but not safe
		else:
			base_pressure = 0.5  # Big lead

	# Final holes increase pressure
	if tournament.holes_remaining <= 2:
		base_pressure *= 1.5

	# Apply leader's clutch factor
	var clutch_factor := leader.clutch / 20.0
	base_pressure *= (1.0 - clutch_factor * 0.5)

	# Apply leader's curse trinket
	if has_curse:
		base_pressure *= 1.5

	# Apply pressure tendency
	if leader.pressure_tendency == "choke":
		base_pressure *= 1.3
	elif leader.pressure_tendency == "clutch":
		base_pressure *= 0.7

	return base_pressure


static func simulate_playoff(player: GolferAttributes, leader: GolferAttributes) -> bool:
	"""
	Simulate a sudden death playoff.
	Returns true if player wins.
	"""
	var player_skill := player.get_average_rating() + (player.clutch * 0.5)
	var leader_skill := leader.get_average_rating() + (leader.clutch * 0.5)

	# Add some randomness
	player_skill += randf_range(-3, 3)
	leader_skill += randf_range(-3, 3)

	# Apply pressure tendencies
	if player.pressure_tendency == "clutch":
		player_skill += 2
	elif player.pressure_tendency == "choke":
		player_skill -= 2

	if leader.pressure_tendency == "clutch":
		leader_skill += 2
	elif leader.pressure_tendency == "choke":
		leader_skill -= 2

	return player_skill > leader_skill
