## Main game scene controller
extends Node3D

@onready var caddie: CaddieController = $Caddie
@onready var course_container: Node3D = $CourseContainer
@onready var hud: HUD = $UILayer/HUD
@onready var leaderboard: LeaderboardUI = $UILayer/Leaderboard

var current_hole_scene: Node3D = null
var ball_node: Node3D = null


func _ready() -> void:
	# Connect to game manager signals
	if GameManager:
		GameManager.hole_started.connect(_on_hole_started)
		GameManager.hole_completed.connect(_on_hole_completed)
		GameManager.shot_completed.connect(_on_shot_completed)
		GameManager.run_completed.connect(_on_run_completed)

	# Connect caddie signals
	if caddie:
		caddie.target_selected.connect(_on_target_selected)
		caddie.caddie_mode_entered.connect(_on_caddie_mode_entered)
		caddie.caddie_mode_exited.connect(_on_caddie_mode_exited)


func _on_hole_started(hole_number: int) -> void:
	print("Starting hole %d" % hole_number)

	# Load hole scene
	if GameManager and GameManager.current_hole_data:
		_load_hole_scene(GameManager.current_hole_data)

	# Spawn ball at tee
	_spawn_ball()

	# Update HUD
	if hud:
		hud.show_message("Hole %d - Par %d" % [hole_number, GameManager.current_hole_data.par], Color.WHITE, 3.0)


func _load_hole_scene(hole_data: HoleData) -> void:
	# Remove old hole
	if current_hole_scene:
		current_hole_scene.queue_free()

	# Load new hole scene
	if hole_data.scene_path and ResourceLoader.exists(hole_data.scene_path):
		var scene := load(hole_data.scene_path)
		if scene:
			current_hole_scene = scene.instantiate()
			course_container.add_child(current_hole_scene)
	else:
		# Use placeholder
		print("Hole scene not found, using placeholder")


func _spawn_ball() -> void:
	if ball_node:
		ball_node.queue_free()

	# Create simple ball representation
	ball_node = CSGSphere3D.new()
	ball_node.radius = 0.02  # Golf ball is about 4cm diameter
	ball_node.material = StandardMaterial3D.new()
	ball_node.material.albedo_color = Color.WHITE
	course_container.add_child(ball_node)

	# Position at current ball position
	if GameManager:
		ball_node.global_position = GameManager.ball_position


func _on_hole_completed(hole_number: int, score: int) -> void:
	print("Completed hole %d with score %d" % [hole_number, score])

	# Show result
	var score_text := _score_to_text(score)
	if hud:
		var color := Color.GREEN if score < 0 else (Color.WHITE if score == 0 else Color.RED)
		hud.show_message(score_text, color, 3.0)

	# Show leaderboard update
	if leaderboard and GameManager:
		leaderboard.show_hole_result(hole_number, score, GameManager.tournament.leader_hole_scores[-1])


func _score_to_text(score: int) -> String:
	match score:
		-3: return "ALBATROSS!"
		-2: return "EAGLE!"
		-1: return "BIRDIE!"
		0: return "PAR"
		1: return "BOGEY"
		2: return "DOUBLE BOGEY"
		_:
			if score < 0:
				return "%d UNDER!" % abs(score)
			else:
				return "+%d" % score


func _on_shot_completed(outcome: ShotOutcome) -> void:
	# Update ball position
	if ball_node and GameManager:
		ball_node.global_position = GameManager.ball_position

	# Play sound
	if AudioManager and GameManager:
		AudioManager.play_ball_land_sound(outcome.resulting_lie)

		# Crowd reaction
		if outcome.result == Enums.ShotResult.PERFECT:
			AudioManager.play_crowd_reaction(true, 1.0)
		elif outcome.result == Enums.ShotResult.DISASTER:
			AudioManager.play_crowd_reaction(false, 0.5)


func _on_run_completed(won: bool) -> void:
	print("Run completed! Won: %s" % won)

	# Transition to run complete scene
	await get_tree().create_timer(2.0).timeout

	if won:
		get_tree().change_scene_to_file("res://scenes/main/trinket_select.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main/run_complete.tscn")


func _on_target_selected(position: Vector3) -> void:
	# Visual feedback for target selection
	print("Target selected at: %s" % position)


func _on_caddie_mode_entered() -> void:
	# Show shot UI
	pass


func _on_caddie_mode_exited() -> void:
	# Hide shot UI
	pass
