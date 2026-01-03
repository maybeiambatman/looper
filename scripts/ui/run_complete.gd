## Run completion screen
extends Control

@onready var result_label: Label = $VBox/ResultLabel
@onready var won_lost_label: Label = $VBox/WonLostLabel
@onready var stats_label: Label = $VBox/StatsPanel/StatsLabel
@onready var continue_button: Button = $VBox/ContinueButton


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	_update_display()


func _update_display() -> void:
	if not GameManager or not GameManager.current_run:
		return

	var run := GameManager.current_run
	var won := run.won

	# Update title
	if won:
		result_label.text = "VICTORY!"
		result_label.modulate = Color.GOLD
		won_lost_label.text = "YOU WON THE TOURNAMENT!"
		won_lost_label.modulate = Color.GREEN
	else:
		result_label.text = "RUN COMPLETE"
		result_label.modulate = Color.WHITE
		won_lost_label.text = "YOU CAME UP SHORT"
		won_lost_label.modulate = Color.RED

	# Calculate XP
	var xp_earned := _calculate_xp(run)

	# Stats display
	var score_display := run.get_score_display()
	stats_label.text = """Final Score: %s
Shots Taken: %d
Good Decisions: %d
Bad Decisions: %d

XP Earned: %d
Caddie Level: %d""" % [
		score_display,
		run.shots_taken,
		run.good_decisions,
		run.bad_decisions,
		xp_earned,
		GameManager.meta_progress.caddie_level
	]


func _calculate_xp(run: RunData) -> int:
	var xp := 0
	xp += run.shots_taken * 5
	xp += run.good_decisions * 20
	xp -= run.bad_decisions * 5

	if run.won:
		xp += 200
		xp += run.difficulty * 50

	return maxi(0, xp)


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
