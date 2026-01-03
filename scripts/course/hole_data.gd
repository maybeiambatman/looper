## Data class containing all information about a single hole
class_name HoleData
extends Resource

@export var hole_number: int = 14
@export var par: int = 4
@export var total_yardage: int = 420
@export var hole_type: Enums.HoleType = Enums.HoleType.PAR_4_POSITIONAL
@export var scene_path: String = ""

# Visual references
@export var map_texture_path: String = ""
@export var green_texture_path: String = ""

# Landmarks and yardages for the yardage book
@export var landmarks: Array[Dictionary] = []  # [{name: "Front bunker", yardage: 150}, ...]

# Pin position (varies each run)
@export var pin_position: Vector3 = Vector3.ZERO
@export var pin_position_description: String = "Center"
@export var pin_paces: int = 15
@export var pin_from_edge: String = "front"

# Green details
@export var green_depth: int = 30
@export var green_slope_description: String = "Back to front"
@export var green_speed: String = "Fast"  # "Slow", "Medium", "Fast", "Lightning"

# Hazards
@export var has_water: bool = false
@export var water_position: String = ""
@export var bunker_positions: Array[String] = []

# Caddie notes
@export var caddie_notes: String = ""

# Tee position for spawning
@export var tee_position: Vector3 = Vector3.ZERO
@export var tee_direction: Vector3 = Vector3.FORWARD


func get_hole_name() -> String:
	return "Hole %d" % hole_number


func get_par_display() -> String:
	return "Par %d" % par


func get_yardage_display() -> String:
	return "%d yards" % total_yardage


func get_front_of_green_yardage() -> int:
	for landmark in landmarks:
		if "front" in landmark.get("name", "").to_lower() and "green" in landmark.get("name", "").to_lower():
			return landmark.get("yardage", total_yardage - 15)
	return total_yardage - green_depth


func get_back_of_green_yardage() -> int:
	for landmark in landmarks:
		if "back" in landmark.get("name", "").to_lower() and "green" in landmark.get("name", "").to_lower():
			return landmark.get("yardage", total_yardage + 15)
	return total_yardage + 5


func add_landmark(name: String, yardage: int) -> void:
	landmarks.append({"name": name, "yardage": yardage})


func to_dict() -> Dictionary:
	return {
		"hole_number": hole_number,
		"par": par,
		"total_yardage": total_yardage,
		"hole_type": hole_type,
		"scene_path": scene_path,
		"map_texture_path": map_texture_path,
		"green_texture_path": green_texture_path,
		"landmarks": landmarks,
		"pin_position": {"x": pin_position.x, "y": pin_position.y, "z": pin_position.z},
		"pin_position_description": pin_position_description,
		"pin_paces": pin_paces,
		"pin_from_edge": pin_from_edge,
		"green_depth": green_depth,
		"green_slope_description": green_slope_description,
		"green_speed": green_speed,
		"has_water": has_water,
		"water_position": water_position,
		"bunker_positions": bunker_positions,
		"caddie_notes": caddie_notes,
		"tee_position": {"x": tee_position.x, "y": tee_position.y, "z": tee_position.z},
		"tee_direction": {"x": tee_direction.x, "y": tee_direction.y, "z": tee_direction.z}
	}


static func from_dict(data: Dictionary) -> HoleData:
	var hole := HoleData.new()
	hole.hole_number = data.get("hole_number", 14)
	hole.par = data.get("par", 4)
	hole.total_yardage = data.get("total_yardage", 420)
	hole.hole_type = data.get("hole_type", Enums.HoleType.PAR_4_POSITIONAL)
	hole.scene_path = data.get("scene_path", "")
	hole.map_texture_path = data.get("map_texture_path", "")
	hole.green_texture_path = data.get("green_texture_path", "")
	hole.landmarks = data.get("landmarks", [])

	if data.has("pin_position"):
		var pp = data.pin_position
		hole.pin_position = Vector3(pp.x, pp.y, pp.z)

	if data.has("tee_position"):
		var tp = data.tee_position
		hole.tee_position = Vector3(tp.x, tp.y, tp.z)

	if data.has("tee_direction"):
		var td = data.tee_direction
		hole.tee_direction = Vector3(td.x, td.y, td.z)

	hole.pin_position_description = data.get("pin_position_description", "Center")
	hole.pin_paces = data.get("pin_paces", 15)
	hole.pin_from_edge = data.get("pin_from_edge", "front")
	hole.green_depth = data.get("green_depth", 30)
	hole.green_slope_description = data.get("green_slope_description", "")
	hole.green_speed = data.get("green_speed", "Fast")
	hole.has_water = data.get("has_water", false)
	hole.water_position = data.get("water_position", "")
	hole.bunker_positions = data.get("bunker_positions", [])
	hole.caddie_notes = data.get("caddie_notes", "")

	return hole
