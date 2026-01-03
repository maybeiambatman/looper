## Main menu controller
extends Control

@onready var new_run_button: Button = $VBoxContainer/NewRunButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var stats_label: Label = $VBoxContainer/StatsPanel/StatsLabel


func _ready() -> void:
	# Connect buttons
	new_run_button.pressed.connect(_on_new_run_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Check for existing save
	continue_button.disabled = not SaveManager.has_save()

	# Update stats display
	_update_stats()


func _update_stats() -> void:
	if GameManager and GameManager.meta_progress:
		var meta := GameManager.meta_progress
		stats_label.text = "Caddie Level: %d\nTotal Runs: %d | Wins: %d | Win Rate: %.1f%%" % [
			meta.caddie_level,
			meta.total_runs,
			meta.wins,
			meta.get_win_rate() * 100
		]
	else:
		stats_label.text = "Caddie Level: 1\nTotal Runs: 0 | Wins: 0"


func _on_new_run_pressed() -> void:
	# Show difficulty selection or start directly
	_start_new_run(1)


func _start_new_run(difficulty: int) -> void:
	if GameManager:
		GameManager.start_new_run(difficulty)
		get_tree().change_scene_to_file("res://scenes/main/game.tscn")


func _on_continue_pressed() -> void:
	if GameManager:
		if GameManager.continue_run():
			get_tree().change_scene_to_file("res://scenes/main/game.tscn")


func _on_settings_pressed() -> void:
	# TODO: Show settings menu
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()
