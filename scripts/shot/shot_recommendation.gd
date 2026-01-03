## Data class representing a caddie's shot recommendation
class_name ShotRecommendation
extends RefCounted

var club: String = "7_iron"
var target_position: Vector3 = Vector3.ZERO
var target_direction: Vector3 = Vector3.FORWARD
var shot_shape: Enums.ShotShape = Enums.ShotShape.STRAIGHT
var shot_type: Enums.ShotType = Enums.ShotType.APPROACH
var intended_distance: float = 150.0
var start_position: Vector3 = Vector3.ZERO
var wind_adjustment_accuracy: float = 0.5  # How well caddie accounted for wind (0.0 to 1.0)


func get_summary() -> String:
	var club_name := club.replace("_", " ").capitalize()
	var shape_name := Enums.get_shot_shape_name(shot_shape)
	return "%s, %d yards, %s" % [club_name, int(intended_distance), shape_name]


func get_club_display_name() -> String:
	return club.replace("_", "-").to_upper()


func calculate_target_distance() -> float:
	return start_position.distance_to(target_position)


func to_dict() -> Dictionary:
	return {
		"club": club,
		"target_position": {
			"x": target_position.x,
			"y": target_position.y,
			"z": target_position.z
		},
		"target_direction": {
			"x": target_direction.x,
			"y": target_direction.y,
			"z": target_direction.z
		},
		"shot_shape": shot_shape,
		"shot_type": shot_type,
		"intended_distance": intended_distance,
		"start_position": {
			"x": start_position.x,
			"y": start_position.y,
			"z": start_position.z
		},
		"wind_adjustment_accuracy": wind_adjustment_accuracy
	}


static func from_dict(data: Dictionary) -> ShotRecommendation:
	var rec := ShotRecommendation.new()
	rec.club = data.get("club", "7_iron")

	if data.has("target_position"):
		var tp = data.target_position
		rec.target_position = Vector3(tp.x, tp.y, tp.z)

	if data.has("target_direction"):
		var td = data.target_direction
		rec.target_direction = Vector3(td.x, td.y, td.z)

	if data.has("start_position"):
		var sp = data.start_position
		rec.start_position = Vector3(sp.x, sp.y, sp.z)

	rec.shot_shape = data.get("shot_shape", Enums.ShotShape.STRAIGHT)
	rec.shot_type = data.get("shot_type", Enums.ShotType.APPROACH)
	rec.intended_distance = data.get("intended_distance", 150.0)
	rec.wind_adjustment_accuracy = data.get("wind_adjustment_accuracy", 0.5)

	return rec
