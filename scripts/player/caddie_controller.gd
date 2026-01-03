## First-person caddie controller
extends CharacterBody3D
class_name CaddieController

signal target_selected(position: Vector3)
signal caddie_mode_entered()
signal caddie_mode_exited()
signal look_at_ball()

# Movement settings
@export var walk_speed: float = 4.0
@export var crouch_speed: float = 2.0
@export var mouse_sensitivity: float = 0.002

# State
var is_crouching: bool = false
var can_move: bool = true
var is_in_caddie_mode: bool = false
var is_in_menu: bool = false

# Look target for shot recommendation
var current_look_target: Vector3 = Vector3.ZERO
var look_target_valid: bool = false

# References (set via @onready or assigned in _ready)
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var interaction_ray: RayCast3D = $CameraPivot/Camera3D/InteractionRay
@onready var ui_layer: CanvasLayer = $UILayer

# UI References
var yardage_book_ui: Control = null
var shot_ui: Control = null
var hud: Control = null


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Setup camera if not already done
	if not camera_pivot:
		camera_pivot = Node3D.new()
		camera_pivot.name = "CameraPivot"
		add_child(camera_pivot)
		camera_pivot.position.y = 1.6  # Eye height

	if not camera:
		camera = Camera3D.new()
		camera.name = "Camera3D"
		camera_pivot.add_child(camera)

	if not interaction_ray:
		interaction_ray = RayCast3D.new()
		interaction_ray.name = "InteractionRay"
		interaction_ray.target_position = Vector3(0, 0, -500)  # 500m range
		interaction_ray.enabled = true
		camera.add_child(interaction_ray)

	# Connect to game manager signals
	if GameManager:
		GameManager.hole_started.connect(_on_hole_started)
		GameManager.shot_completed.connect(_on_shot_completed)


func _input(event: InputEvent) -> void:
	if is_in_menu:
		return

	# Mouse look
	if event is InputEventMouseMotion and not is_in_caddie_mode:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
			camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -PI/2 + 0.1, PI/2 - 0.1)

	# Toggle yardage book
	if event.is_action_pressed("toggle_book"):
		toggle_yardage_book()

	# Toggle crouch
	if event.is_action_pressed("crouch"):
		toggle_crouch()

	# Enter/exit caddie mode
	if event.is_action_pressed("caddie_mode"):
		if is_in_caddie_mode:
			exit_caddie_mode()
		else:
			enter_caddie_mode()

	# Confirm in caddie mode
	if event.is_action_pressed("confirm") and is_in_caddie_mode:
		confirm_target()

	# Cancel
	if event.is_action_pressed("cancel"):
		if is_in_caddie_mode:
			exit_caddie_mode()
		elif yardage_book_ui and yardage_book_ui.visible:
			toggle_yardage_book()


func _physics_process(delta: float) -> void:
	if not can_move or is_in_menu:
		return

	# Get input direction
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Apply movement
	var speed := crouch_speed if is_crouching else walk_speed
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0

	move_and_slide()

	# Update look target for shot recommendation
	_update_look_target()


func _update_look_target() -> void:
	if interaction_ray and interaction_ray.is_colliding():
		current_look_target = interaction_ray.get_collision_point()
		look_target_valid = true
	else:
		look_target_valid = false


func toggle_yardage_book() -> void:
	if yardage_book_ui:
		yardage_book_ui.visible = not yardage_book_ui.visible

		if yardage_book_ui.visible:
			# Show current hole data
			if GameManager and GameManager.current_hole_data:
				yardage_book_ui.show_hole(GameManager.current_hole_data)


func toggle_crouch() -> void:
	is_crouching = not is_crouching

	var tween := create_tween()
	var target_height := 0.5 if is_crouching else 1.6
	tween.tween_property(camera_pivot, "position:y", target_height, 0.2)


func enter_caddie_mode() -> void:
	is_in_caddie_mode = true
	can_move = false
	caddie_mode_entered.emit()

	if shot_ui:
		shot_ui.visible = true
		shot_ui.start_recommendation(current_look_target)

	# Change to shot selection mouse mode - still captured but show crosshair
	# In full implementation, might want partial mouse freedom


func exit_caddie_mode() -> void:
	is_in_caddie_mode = false
	can_move = true
	caddie_mode_exited.emit()

	if shot_ui:
		shot_ui.visible = false


func confirm_target() -> void:
	if look_target_valid:
		target_selected.emit(current_look_target)

		if shot_ui:
			shot_ui.set_target(current_look_target)


func get_look_direction() -> Vector3:
	return -camera.global_transform.basis.z


func get_camera_position() -> Vector3:
	return camera.global_position


func teleport_to(position: Vector3) -> void:
	global_position = position


func look_at_position(target: Vector3) -> void:
	var direction := (target - global_position).normalized()
	direction.y = 0  # Keep level

	if direction.length_squared() > 0.01:
		var target_rotation := atan2(-direction.x, -direction.z)
		rotation.y = target_rotation


func set_menu_mode(in_menu: bool) -> void:
	is_in_menu = in_menu
	can_move = not in_menu

	if in_menu:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_hole_started(_hole_number: int) -> void:
	# Teleport to tee box
	if GameManager and GameManager.current_hole_data:
		var tee_pos := GameManager.current_hole_data.tee_position
		teleport_to(tee_pos + Vector3(2, 0, 0))  # Stand next to player

		# Look toward the hole
		var hole_dir := GameManager.current_hole_data.tee_direction
		look_at_position(tee_pos + hole_dir * 10)


func _on_shot_completed(outcome: ShotOutcome) -> void:
	# After shot, might want to walk to ball
	look_at_ball.emit()
