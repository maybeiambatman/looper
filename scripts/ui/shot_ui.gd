## Shot recommendation UI
extends Control
class_name ShotUI

signal shot_confirmed(recommendation: ShotRecommendation)
signal shot_cancelled()

enum State { CLUB_SELECT, TARGET_SELECT, SHAPE_SELECT, DISTANCE_SELECT, CONFIRM }

# Current state
var current_state: State = State.CLUB_SELECT
var current_recommendation: ShotRecommendation = null

# Club list
var clubs: Array[String] = [
	"driver", "3_wood", "5_wood", "hybrid",
	"4_iron", "5_iron", "6_iron", "7_iron", "8_iron", "9_iron",
	"pw", "gw", "sw", "lw", "putter"
]
var selected_club_index: int = 6  # 7_iron default

# Shape options
var shapes: Array[Enums.ShotShape] = [
	Enums.ShotShape.STRAIGHT,
	Enums.ShotShape.FADE,
	Enums.ShotShape.DRAW,
	Enums.ShotShape.PUNCH,
	Enums.ShotShape.HIGH
]
var selected_shape_index: int = 0

# UI References
@onready var state_label: Label = $Panel/StateLabel
@onready var club_label: Label = $Panel/ClubLabel
@onready var distance_label: Label = $Panel/DistanceLabel
@onready var target_label: Label = $Panel/TargetLabel
@onready var shape_label: Label = $Panel/ShapeLabel
@onready var instruction_label: Label = $Panel/InstructionLabel
@onready var crosshair: Control = $Crosshair


func _ready() -> void:
	visible = false
	current_recommendation = ShotRecommendation.new()


func start_recommendation(initial_target: Vector3) -> void:
	current_recommendation = ShotRecommendation.new()
	current_recommendation.target_position = initial_target

	# Start with suggested club based on distance
	if GameManager and GameManager.player:
		var suggested := GameManager.get_suggested_club()
		selected_club_index = clubs.find(suggested)
		if selected_club_index < 0:
			selected_club_index = 6

	current_state = State.CLUB_SELECT
	_update_display()


func set_target(target: Vector3) -> void:
	current_recommendation.target_position = target
	if current_state == State.TARGET_SELECT:
		current_state = State.SHAPE_SELECT
	_update_display()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	# Scroll to change selection
	if event.is_action_pressed("scroll_up"):
		_scroll_selection(-1)
	elif event.is_action_pressed("scroll_down"):
		_scroll_selection(1)

	# Confirm current step
	if event.is_action_pressed("confirm"):
		_advance_state()

	# Cancel/go back
	if event.is_action_pressed("cancel"):
		_go_back()


func _scroll_selection(direction: int) -> void:
	match current_state:
		State.CLUB_SELECT:
			selected_club_index = clampi(selected_club_index + direction, 0, clubs.size() - 1)
		State.SHAPE_SELECT:
			selected_shape_index = clampi(selected_shape_index + direction, 0, shapes.size() - 1)
		State.DISTANCE_SELECT:
			current_recommendation.intended_distance += direction * 5

	_update_display()


func _advance_state() -> void:
	match current_state:
		State.CLUB_SELECT:
			current_recommendation.club = clubs[selected_club_index]
			current_state = State.TARGET_SELECT
		State.TARGET_SELECT:
			current_state = State.SHAPE_SELECT
		State.SHAPE_SELECT:
			current_recommendation.shot_shape = shapes[selected_shape_index]
			current_state = State.DISTANCE_SELECT
			# Set initial distance based on club
			if GameManager and GameManager.player:
				current_recommendation.intended_distance = GameManager.player.get_club_distance(current_recommendation.club)
		State.DISTANCE_SELECT:
			current_state = State.CONFIRM
		State.CONFIRM:
			_confirm_shot()

	_update_display()


func _go_back() -> void:
	match current_state:
		State.CLUB_SELECT:
			shot_cancelled.emit()
		State.TARGET_SELECT:
			current_state = State.CLUB_SELECT
		State.SHAPE_SELECT:
			current_state = State.TARGET_SELECT
		State.DISTANCE_SELECT:
			current_state = State.SHAPE_SELECT
		State.CONFIRM:
			current_state = State.DISTANCE_SELECT

	_update_display()


func _confirm_shot() -> void:
	# Finalize recommendation
	if GameManager:
		current_recommendation.start_position = GameManager.ball_position
		current_recommendation.shot_type = _determine_shot_type()

		# Calculate wind adjustment accuracy (simplified - in full game this would be more complex)
		current_recommendation.wind_adjustment_accuracy = randf_range(0.4, 0.9)

	shot_confirmed.emit(current_recommendation)


func _determine_shot_type() -> Enums.ShotType:
	if current_recommendation.club == "putter":
		return Enums.ShotType.PUTT
	elif current_recommendation.club in ["sw", "lw", "gw"]:
		if GameManager and GameManager.get_yardage_to_pin() < 50:
			return Enums.ShotType.SHORT_GAME
	elif current_recommendation.club == "driver":
		return Enums.ShotType.DRIVE

	return Enums.ShotType.APPROACH


func _update_display() -> void:
	# Update state label
	if state_label:
		match current_state:
			State.CLUB_SELECT:
				state_label.text = "SELECT CLUB"
			State.TARGET_SELECT:
				state_label.text = "SELECT TARGET"
			State.SHAPE_SELECT:
				state_label.text = "SELECT SHOT SHAPE"
			State.DISTANCE_SELECT:
				state_label.text = "SET DISTANCE"
			State.CONFIRM:
				state_label.text = "CONFIRM SHOT"

	# Update club display
	if club_label:
		var club_name := clubs[selected_club_index].replace("_", " ").to_upper()
		var club_distance := 0
		if GameManager and GameManager.player:
			club_distance = GameManager.player.get_club_distance(clubs[selected_club_index])
		club_label.text = "%s (%d yds)" % [club_name, club_distance]

	# Update distance
	if distance_label:
		distance_label.text = "%d yards" % int(current_recommendation.intended_distance)

	# Update target info
	if target_label:
		var dist_to_target := 0.0
		if GameManager:
			dist_to_target = GameManager.get_yardage_to_pin()
		target_label.text = "Pin: %d yards" % int(dist_to_target)

	# Update shape
	if shape_label:
		shape_label.text = Enums.get_shot_shape_name(shapes[selected_shape_index])

	# Update instructions
	if instruction_label:
		match current_state:
			State.CLUB_SELECT:
				instruction_label.text = "Scroll to select club, Enter to confirm"
			State.TARGET_SELECT:
				instruction_label.text = "Look at target and click to select"
			State.SHAPE_SELECT:
				instruction_label.text = "Scroll to select shot shape"
			State.DISTANCE_SELECT:
				instruction_label.text = "Scroll to adjust distance"
			State.CONFIRM:
				instruction_label.text = "Press Enter to execute shot"

	# Show/hide crosshair based on state
	if crosshair:
		crosshair.visible = current_state == State.TARGET_SELECT
