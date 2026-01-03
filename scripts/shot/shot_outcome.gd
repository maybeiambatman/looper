## Data class representing the outcome of a golf shot
class_name ShotOutcome
extends RefCounted

var result: Enums.ShotResult = Enums.ShotResult.ACCEPTABLE
var distance_error: float = 0.0  # Yards short (-) or long (+)
var direction_error: float = 0.0  # Yards left (-) or right (+)
var landing_position: Vector3 = Vector3.ZERO
var final_position: Vector3 = Vector3.ZERO  # After roll
var resulting_lie: Enums.LieType = Enums.LieType.FAIRWAY
var description: String = ""
var made_putt: bool = false  # Only relevant for putts


func generate_description(was_putt: bool = false) -> void:
	if was_putt:
		_generate_putt_description()
	else:
		_generate_shot_description()


func _generate_putt_description() -> void:
	match result:
		Enums.ShotResult.PERFECT:
			if made_putt:
				description = "Drains it!"
			else:
				description = "Perfect stroke, lipped out!"
		Enums.ShotResult.GOOD:
			if made_putt:
				description = "Rolls in nicely."
			else:
				description = "Just missed, tap-in."
		Enums.ShotResult.ACCEPTABLE:
			description = "A few feet left."
		Enums.ShotResult.POOR:
			description = "Misread it badly."
		Enums.ShotResult.DISASTER:
			description = "Three-putt territory."


func _generate_shot_description() -> void:
	match result:
		Enums.ShotResult.PERFECT:
			description = "Stuck it close!"
		Enums.ShotResult.GOOD:
			description = "Good shot, on target."
		Enums.ShotResult.ACCEPTABLE:
			description = "Safe, but work to do."
		Enums.ShotResult.POOR:
			description = "Missed the target."
		Enums.ShotResult.DISASTER:
			_generate_disaster_description()


func _generate_disaster_description() -> void:
	match resulting_lie:
		Enums.LieType.WATER:
			description = "Splash! Found the water."
		Enums.LieType.GREENSIDE_BUNKER, Enums.LieType.FAIRWAY_BUNKER:
			description = "Buried in the bunker."
		Enums.LieType.HEAVY_ROUGH:
			description = "Deep in the cabbage."
		Enums.LieType.BURIED:
			description = "Plugged badly."
		_:
			description = "Found trouble."


func get_result_color() -> Color:
	return Enums.get_result_color(result)


func get_distance_from_target() -> float:
	return sqrt(distance_error * distance_error + direction_error * direction_error)


func is_on_green() -> bool:
	return resulting_lie == Enums.LieType.GREEN


func is_in_trouble() -> bool:
	return resulting_lie in [
		Enums.LieType.WATER,
		Enums.LieType.HEAVY_ROUGH,
		Enums.LieType.BURIED,
		Enums.LieType.FAIRWAY_BUNKER,
		Enums.LieType.GREENSIDE_BUNKER
	]


func to_dict() -> Dictionary:
	return {
		"result": result,
		"distance_error": distance_error,
		"direction_error": direction_error,
		"landing_position": {
			"x": landing_position.x,
			"y": landing_position.y,
			"z": landing_position.z
		},
		"final_position": {
			"x": final_position.x,
			"y": final_position.y,
			"z": final_position.z
		},
		"resulting_lie": resulting_lie,
		"description": description,
		"made_putt": made_putt
	}


static func from_dict(data: Dictionary) -> ShotOutcome:
	var outcome := ShotOutcome.new()
	outcome.result = data.get("result", Enums.ShotResult.ACCEPTABLE)
	outcome.distance_error = data.get("distance_error", 0.0)
	outcome.direction_error = data.get("direction_error", 0.0)

	if data.has("landing_position"):
		var lp = data.landing_position
		outcome.landing_position = Vector3(lp.x, lp.y, lp.z)

	if data.has("final_position"):
		var fp = data.final_position
		outcome.final_position = Vector3(fp.x, fp.y, fp.z)

	outcome.resulting_lie = data.get("resulting_lie", Enums.LieType.FAIRWAY)
	outcome.description = data.get("description", "")
	outcome.made_putt = data.get("made_putt", false)

	return outcome
