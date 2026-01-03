## Tracks current environmental conditions for a hole
class_name HoleConditions
extends RefCounted

# Wind
var wind_direction: Vector3 = Vector3.FORWARD
var wind_speed: float = 10.0  # mph
var wind_gust_variance: float = 3.0

# Temperature affects ball flight
var temperature: float = 72.0  # Fahrenheit
var temperature_description: String = "Mild"

# Humidity/Air density
var humidity: float = 0.5  # 0.0 to 1.0
var air_density: String = "Normal"  # "Thin", "Normal", "Heavy"

# Green conditions
var green_firmness: String = "Medium"  # "Soft", "Medium", "Firm"
var green_speed: String = "Fast"  # "Slow", "Medium", "Fast", "Lightning"

# Time of day affects conditions
var time_of_day: String = "Afternoon"  # "Morning", "Afternoon"
var is_dewy: bool = false


func get_wind_effect_multiplier() -> float:
	"""Returns a multiplier for how much wind affects shots"""
	if wind_speed < 5:
		return 0.0
	elif wind_speed < 10:
		return 0.5
	elif wind_speed < 15:
		return 1.0
	elif wind_speed < 20:
		return 1.5
	else:
		return 2.0


func get_temperature_distance_modifier() -> float:
	"""Hot air = longer shots, cold air = shorter shots"""
	# At 72F = no modifier, +/- 1% per 10 degrees
	var diff := temperature - 72.0
	return 1.0 + (diff / 1000.0)


func get_air_density_modifier() -> float:
	"""Affects ball flight distance"""
	match air_density:
		"Thin":
			return 1.03  # Ball travels farther
		"Heavy":
			return 0.97  # Ball doesn't travel as far
		_:
			return 1.0


func get_green_holding_modifier() -> float:
	"""How much the ball checks on the green"""
	var base := 1.0

	match green_firmness:
		"Soft":
			base = 1.3  # Ball checks more
		"Firm":
			base = 0.7  # Ball releases more
		_:
			base = 1.0

	if is_dewy:
		base *= 0.9  # Wet greens are slicker

	return base


func get_green_speed_modifier() -> float:
	"""Affects putting distance calculations"""
	match green_speed:
		"Slow":
			return 0.8
		"Fast":
			return 1.2
		"Lightning":
			return 1.5
		_:
			return 1.0


func get_wind_description() -> String:
	"""Human-readable wind description for caddie"""
	var speed_desc: String
	if wind_speed < 5:
		speed_desc = "Calm"
	elif wind_speed < 10:
		speed_desc = "Light breeze"
	elif wind_speed < 15:
		speed_desc = "Moderate wind"
	elif wind_speed < 20:
		speed_desc = "Strong wind"
	else:
		speed_desc = "Very strong wind"

	var direction_desc := _get_wind_direction_name()

	if wind_speed < 5:
		return speed_desc
	else:
		return "%s %s" % [speed_desc, direction_desc]


func _get_wind_direction_name() -> String:
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


func calculate_wind_effect(shot_direction: Vector3, shot_distance: float) -> Vector3:
	"""Calculate how wind affects a shot"""
	if wind_speed < 3:
		return Vector3.ZERO

	# Cross wind pushes ball sideways
	var right := shot_direction.cross(Vector3.UP).normalized()
	var cross_component := wind_direction.dot(right)
	var lateral_push := cross_component * wind_speed * 0.4 * (shot_distance / 200.0)

	# Head/tail wind affects distance
	var head_tail := wind_direction.dot(shot_direction)
	var distance_effect := -head_tail * wind_speed * 0.3 * (shot_distance / 200.0)

	return Vector3(lateral_push, 0, distance_effect)


static func generate_random(difficulty: int = 1) -> HoleConditions:
	"""Generate random conditions with difficulty scaling"""
	var conditions := HoleConditions.new()

	# Wind - harder = more wind
	var max_wind := 10.0 + (difficulty * 3.0)
	conditions.wind_speed = randf_range(0, max_wind)
	conditions.wind_gust_variance = conditions.wind_speed * 0.2

	# Random wind direction
	var wind_angle := randf() * TAU
	conditions.wind_direction = Vector3(sin(wind_angle), 0, cos(wind_angle))

	# Temperature
	conditions.temperature = randf_range(55, 90)
	if conditions.temperature < 65:
		conditions.temperature_description = "Cool"
	elif conditions.temperature > 85:
		conditions.temperature_description = "Hot"
	else:
		conditions.temperature_description = "Mild"

	# Humidity
	conditions.humidity = randf()
	if conditions.humidity > 0.7:
		conditions.air_density = "Heavy"
	elif conditions.humidity < 0.3:
		conditions.air_density = "Thin"
	else:
		conditions.air_density = "Normal"

	# Green conditions
	var firmness_roll := randf()
	if firmness_roll < 0.3:
		conditions.green_firmness = "Soft"
	elif firmness_roll > 0.7:
		conditions.green_firmness = "Firm"
	else:
		conditions.green_firmness = "Medium"

	var speed_options := ["Medium", "Fast", "Fast", "Lightning"]
	conditions.green_speed = speed_options[randi() % speed_options.size()]

	# Time of day
	conditions.time_of_day = "Morning" if randf() > 0.5 else "Afternoon"
	conditions.is_dewy = conditions.time_of_day == "Morning" and randf() > 0.7

	return conditions


func to_dict() -> Dictionary:
	return {
		"wind_direction": {"x": wind_direction.x, "y": wind_direction.y, "z": wind_direction.z},
		"wind_speed": wind_speed,
		"wind_gust_variance": wind_gust_variance,
		"temperature": temperature,
		"temperature_description": temperature_description,
		"humidity": humidity,
		"air_density": air_density,
		"green_firmness": green_firmness,
		"green_speed": green_speed,
		"time_of_day": time_of_day,
		"is_dewy": is_dewy
	}


static func from_dict(data: Dictionary) -> HoleConditions:
	var conditions := HoleConditions.new()

	if data.has("wind_direction"):
		var wd = data.wind_direction
		conditions.wind_direction = Vector3(wd.x, wd.y, wd.z)

	conditions.wind_speed = data.get("wind_speed", 10.0)
	conditions.wind_gust_variance = data.get("wind_gust_variance", 3.0)
	conditions.temperature = data.get("temperature", 72.0)
	conditions.temperature_description = data.get("temperature_description", "Mild")
	conditions.humidity = data.get("humidity", 0.5)
	conditions.air_density = data.get("air_density", "Normal")
	conditions.green_firmness = data.get("green_firmness", "Medium")
	conditions.green_speed = data.get("green_speed", "Fast")
	conditions.time_of_day = data.get("time_of_day", "Afternoon")
	conditions.is_dewy = data.get("is_dewy", false)

	return conditions
