## Main HUD display during gameplay
extends Control
class_name HUD

# Condition displays
@onready var wind_label: Label = $TopBar/WindLabel
@onready var lie_label: Label = $TopBar/LieLabel
@onready var hole_label: Label = $TopBar/HoleLabel
@onready var strokes_label: Label = $TopBar/StrokesLabel

# Distance info
@onready var distance_label: Label = $BottomBar/DistanceLabel

# Pressure indicator
@onready var pressure_indicator: Control = $PressureIndicator
@onready var pressure_label: Label = $PressureIndicator/Label

# Trinket hints (for caddie trinkets)
@onready var hint_container: VBoxContainer = $HintContainer

# Message display
@onready var message_label: Label = $MessageLabel

var message_timer: float = 0.0


func _ready() -> void:
	if GameManager:
		GameManager.hole_started.connect(_on_hole_started)
		GameManager.shot_completed.connect(_on_shot_completed)
		GameManager.pressure_changed.connect(_on_pressure_changed)

	# Hide optional elements
	if hint_container:
		hint_container.visible = false
	if message_label:
		message_label.visible = false


func _process(delta: float) -> void:
	# Update distance display continuously
	_update_distance()

	# Message timer
	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0 and message_label:
			message_label.visible = false


func _update_distance() -> void:
	if not GameManager:
		return

	if distance_label:
		var yardage := GameManager.get_yardage_to_pin()
		if GameManager.is_ball_on_green():
			# Show in feet for putting
			var feet := yardage * 3
			distance_label.text = "%d feet to hole" % int(feet)
		else:
			distance_label.text = "%d yards to pin" % yardage


func _on_hole_started(hole_number: int) -> void:
	if hole_label:
		hole_label.text = "HOLE %d" % hole_number

	if strokes_label:
		strokes_label.text = "Stroke 1"

	# Update wind display
	_update_wind_display()

	# Update lie
	_update_lie_display()


func _on_shot_completed(outcome: ShotOutcome) -> void:
	# Update stroke count
	if strokes_label and GameManager:
		strokes_label.text = "Stroke %d" % (GameManager.strokes_this_hole + 1)

	# Update lie
	_update_lie_display()

	# Show outcome message
	show_message(outcome.description, outcome.get_result_color(), 3.0)


func _on_pressure_changed(pressure_level: Enums.PressureLevel) -> void:
	if not pressure_indicator or not pressure_label:
		return

	pressure_indicator.visible = pressure_level != Enums.PressureLevel.COMFORTABLE

	match pressure_level:
		Enums.PressureLevel.CLOSE:
			pressure_label.text = "CLOSE"
			pressure_indicator.modulate = Color.YELLOW
		Enums.PressureLevel.MUST_PERFORM:
			pressure_label.text = "MUST PERFORM"
			pressure_indicator.modulate = Color.ORANGE
		Enums.PressureLevel.WIN_OR_LOSE:
			pressure_label.text = "WIN OR LOSE"
			pressure_indicator.modulate = Color.RED


func _update_wind_display() -> void:
	if not wind_label or not GameManager or not GameManager.current_conditions:
		return

	var conditions := GameManager.current_conditions
	wind_label.text = conditions.get_wind_description()


func _update_lie_display() -> void:
	if not lie_label or not GameManager:
		return

	lie_label.text = Enums.get_lie_type_name(GameManager.current_lie)


func show_message(text: String, color: Color = Color.WHITE, duration: float = 2.0) -> void:
	if message_label:
		message_label.text = text
		message_label.modulate = color
		message_label.visible = true
		message_timer = duration


func show_hint(hint_text: String) -> void:
	"""Show a trinket-based hint"""
	if not hint_container:
		return

	hint_container.visible = true

	var hint := Label.new()
	hint.text = hint_text
	hint.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	hint_container.add_child(hint)

	# Auto-remove after delay
	await get_tree().create_timer(5.0).timeout
	hint.queue_free()

	if hint_container.get_child_count() == 0:
		hint_container.visible = false


func show_wind_hint(wind_mph: int, direction: String) -> void:
	"""Show wind hint for Wind Sense trinket"""
	show_hint("Wind: %d-%d mph %s" % [wind_mph - 2, wind_mph + 2, direction])


func show_yardage_hint(yardage: int) -> void:
	"""Show yardage hint for Yardage Intuition trinket"""
	show_hint("Looks like about %d yards" % yardage)


func show_temperature_hint(adjustment: String) -> void:
	"""Show temperature hint"""
	show_hint("Ball is playing %s today" % adjustment)
