## Visual and gameplay wind system
extends Node3D
class_name WindSystem

signal wind_changed(direction: Vector3, speed: float)

@export var wind_direction: Vector3 = Vector3.FORWARD
@export var wind_speed: float = 10.0  # mph
@export var gust_variance: float = 3.0

# Visual references - set these in the editor
@export var flag_nodes: Array[Node3D] = []
@export var grass_shader_material: ShaderMaterial = null

# Internal state
var base_wind_direction: Vector3
var base_wind_speed: float
var current_gust: float = 0.0
var gust_timer: float = 0.0


func _ready() -> void:
	base_wind_direction = wind_direction.normalized()
	base_wind_speed = wind_speed
	update_visuals()


func _process(delta: float) -> void:
	# Subtle gust variation
	gust_timer += delta
	if gust_timer > 2.0:
		gust_timer = 0.0
		var target_gust := randf_range(-gust_variance, gust_variance)
		current_gust = lerpf(current_gust, target_gust, 0.3)

	update_visuals()


func set_wind(direction: Vector3, speed: float) -> void:
	base_wind_direction = direction.normalized()
	base_wind_speed = speed
	wind_direction = base_wind_direction
	wind_speed = speed
	gust_variance = speed * 0.2
	wind_changed.emit(wind_direction, wind_speed)


func get_current_speed() -> float:
	return base_wind_speed + current_gust


func update_visuals() -> void:
	var effective_speed := get_current_speed()

	# Update flags
	for flag in flag_nodes:
		if flag and is_instance_valid(flag):
			_update_flag(flag, effective_speed)

	# Update grass shader
	if grass_shader_material:
		grass_shader_material.set_shader_parameter("wind_direction", Vector2(wind_direction.x, wind_direction.z))
		grass_shader_material.set_shader_parameter("wind_strength", effective_speed / 20.0)


func _update_flag(flag: Node3D, effective_speed: float) -> void:
	if flag.has_method("set_wind"):
		flag.set_wind(wind_direction, effective_speed)
	else:
		# Simple rotation toward wind
		var wind_rotation := atan2(wind_direction.x, wind_direction.z)
		flag.rotation.y = lerp_angle(flag.rotation.y, wind_rotation, 0.1)

		# Extend based on speed
		var extend_amount := clampf(effective_speed / 30.0, 0.0, 1.0)
		if flag.has_node("FlagMesh"):
			flag.get_node("FlagMesh").rotation.x = -extend_amount * 0.5


func get_wind_effect_on_shot(shot_direction: Vector3, shot_distance: float) -> Vector3:
	"""Calculate how wind affects ball flight"""
	var effective_speed := get_current_speed()

	if effective_speed < 3:
		return Vector3.ZERO

	# Cross wind pushes ball sideways
	var right := shot_direction.cross(Vector3.UP).normalized()
	var cross_component := wind_direction.dot(right)
	var lateral_push := cross_component * effective_speed * 0.4 * (shot_distance / 200.0)

	# Head/tail wind affects distance
	var head_tail := wind_direction.dot(shot_direction)
	var distance_effect := -head_tail * effective_speed * 0.3 * (shot_distance / 200.0)

	return Vector3(lateral_push, 0, distance_effect)


func get_visual_wind_strength() -> String:
	"""What the caddie would perceive"""
	var effective_speed := get_current_speed()

	if effective_speed < 5:
		return "Calm"
	elif effective_speed < 10:
		return "Light breeze"
	elif effective_speed < 15:
		return "Moderate wind"
	elif effective_speed < 20:
		return "Strong wind"
	else:
		return "Very strong wind"


func get_visual_wind_direction() -> String:
	"""Cardinal direction description"""
	var angle := atan2(wind_direction.x, wind_direction.z)
	var degrees := rad_to_deg(angle)

	if degrees < 0:
		degrees += 360

	if degrees < 22.5 or degrees >= 337.5:
		return "from the north"
	elif degrees < 67.5:
		return "from the northeast"
	elif degrees < 112.5:
		return "from the east"
	elif degrees < 157.5:
		return "from the southeast"
	elif degrees < 202.5:
		return "from the south"
	elif degrees < 247.5:
		return "from the southwest"
	elif degrees < 292.5:
		return "from the west"
	else:
		return "from the northwest"


func get_full_wind_description() -> String:
	var strength := get_visual_wind_strength()
	if strength == "Calm":
		return "Calm conditions"
	return "%s %s" % [strength, get_visual_wind_direction()]
