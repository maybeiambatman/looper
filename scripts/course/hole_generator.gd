## Generates procedural holes for each run
class_name HoleGenerator
extends RefCounted

# Hole archetypes for each position in the final 5
const HOLE_14_TYPES := [Enums.HoleType.PAR_3_SHORT]
const HOLE_15_TYPES := [Enums.HoleType.PAR_4_RISK_REWARD, Enums.HoleType.PAR_5_REACHABLE]
const HOLE_16_TYPES := [Enums.HoleType.PAR_3_LONG, Enums.HoleType.PAR_3_SHORT]
const HOLE_17_TYPES := [Enums.HoleType.PAR_4_POSITIONAL]
const HOLE_18_TYPES := [Enums.HoleType.PAR_5_REACHABLE]

# Pin position variations
const PIN_POSITIONS: Array[String] = ["front-left", "front-center", "front-right", "middle-left", "middle-center", "middle-right", "back-left", "back-center", "back-right"]


static func generate_run(difficulty: int, _trinkets: Array) -> Array:
	"""Generate all 5 holes for a run"""
	var holes: Array = []

	# Hole 14 - Short Par 3
	holes.append(_generate_hole(14, HOLE_14_TYPES[randi() % HOLE_14_TYPES.size()], difficulty))

	# Hole 15 - Risk/Reward
	holes.append(_generate_hole(15, HOLE_15_TYPES[randi() % HOLE_15_TYPES.size()], difficulty))

	# Hole 16 - Signature Par 3
	holes.append(_generate_hole(16, HOLE_16_TYPES[randi() % HOLE_16_TYPES.size()], difficulty))

	# Hole 17 - Demanding Par 4
	holes.append(_generate_hole(17, HOLE_17_TYPES[randi() % HOLE_17_TYPES.size()], difficulty))

	# Hole 18 - Dramatic Par 5
	holes.append(_generate_hole(18, HOLE_18_TYPES[randi() % HOLE_18_TYPES.size()], difficulty))

	return holes


static func _generate_hole(hole_number: int, hole_type: Enums.HoleType, difficulty: int) -> HoleData:
	var hole := HoleData.new()
	hole.hole_number = hole_number
	hole.hole_type = hole_type

	# Set par and yardage based on type
	match hole_type:
		Enums.HoleType.PAR_3_SHORT:
			hole.par = 3
			hole.total_yardage = randi_range(140, 175)
			hole.has_water = randf() > 0.3  # 70% chance of water
			hole.scene_path = "res://scenes/course/holes/par3_island.tscn"
			hole.caddie_notes = "Short iron, favor the fat part of the green."

		Enums.HoleType.PAR_3_LONG:
			hole.par = 3
			hole.total_yardage = randi_range(195, 235)
			hole.has_water = randf() > 0.5
			hole.scene_path = "res://scenes/course/holes/par3_long.tscn"
			hole.caddie_notes = "Long iron or hybrid. Par is a good score here."

		Enums.HoleType.PAR_4_RISK_REWARD:
			hole.par = 4
			hole.total_yardage = randi_range(340, 380)
			hole.has_water = randf() > 0.4
			hole.scene_path = "res://scenes/course/holes/par4_risk_reward.tscn"
			hole.caddie_notes = "Reachable with driver but dangerous. Layup is smart."

		Enums.HoleType.PAR_4_POSITIONAL:
			hole.par = 4
			hole.total_yardage = randi_range(420, 470)
			hole.has_water = randf() > 0.6
			hole.scene_path = "res://scenes/course/holes/par4_positional.tscn"
			hole.caddie_notes = "Accuracy off the tee is crucial. Find the fairway."

		Enums.HoleType.PAR_5_REACHABLE:
			hole.par = 5
			hole.total_yardage = randi_range(530, 575)
			hole.has_water = true  # Par 5s usually have water
			hole.scene_path = "res://scenes/course/holes/par5_eagle.tscn"
			hole.caddie_notes = "Eagle is possible. Two good shots and we're putting for eagle."

	# Generate landmarks
	hole.landmarks = _generate_landmarks(hole)

	# Generate pin position
	_generate_pin_position(hole)

	# Generate bunker positions
	hole.bunker_positions = _generate_bunker_positions(hole_type)

	# Set water position description if applicable
	if hole.has_water:
		hole.water_position = _generate_water_position(hole_type)

	# Green characteristics
	hole.green_depth = randi_range(25, 40)
	hole.green_slope_description = ["Back to front", "Front to back", "Left to right", "Right to left", "Multi-tiered"][randi() % 5]
	hole.green_speed = ["Medium", "Fast", "Fast", "Lightning"][randi() % 4]

	# Set tee position (relative, actual position set by scene)
	hole.tee_position = Vector3(0, 0, 0)
	hole.tee_direction = Vector3(0, 0, 1)

	# Adjust difficulty
	if difficulty > 2:
		hole.green_speed = "Lightning" if randf() > 0.5 else "Fast"

	return hole


static func _generate_landmarks(hole: HoleData) -> Array[Dictionary]:
	var landmarks: Array[Dictionary] = []

	# Front and back of green
	var front_yardage := hole.total_yardage - hole.green_depth / 2 - 5
	var back_yardage := hole.total_yardage + 5

	landmarks.append({"name": "Front of green", "yardage": front_yardage})
	landmarks.append({"name": "Pin", "yardage": hole.total_yardage})
	landmarks.append({"name": "Back of green", "yardage": back_yardage})

	# Add hole-specific landmarks
	match hole.hole_type:
		Enums.HoleType.PAR_3_SHORT, Enums.HoleType.PAR_3_LONG:
			if hole.has_water:
				landmarks.append({"name": "Carry water", "yardage": front_yardage - 10})
			landmarks.append({"name": "Front bunker", "yardage": front_yardage - 5})

		Enums.HoleType.PAR_4_RISK_REWARD:
			landmarks.append({"name": "Layup zone", "yardage": 100})
			landmarks.append({"name": "Fairway bunker", "yardage": hole.total_yardage - 120})
			if hole.has_water:
				landmarks.append({"name": "Water carry", "yardage": hole.total_yardage - 80})

		Enums.HoleType.PAR_4_POSITIONAL:
			landmarks.append({"name": "Fairway bunker left", "yardage": hole.total_yardage - 180})
			landmarks.append({"name": "Fairway bunker right", "yardage": hole.total_yardage - 160})
			landmarks.append({"name": "Ideal landing", "yardage": hole.total_yardage - 150})

		Enums.HoleType.PAR_5_REACHABLE:
			landmarks.append({"name": "Layup zone", "yardage": 100})
			landmarks.append({"name": "Fairway bunker", "yardage": hole.total_yardage - 250})
			landmarks.append({"name": "Going for green carry", "yardage": hole.total_yardage - 80})
			if hole.has_water:
				landmarks.append({"name": "Water in play", "yardage": hole.total_yardage - 60})

	return landmarks


static func _generate_pin_position(hole: HoleData) -> void:
	var pin_pos: String = PIN_POSITIONS[randi() % PIN_POSITIONS.size()]
	var parts: PackedStringArray = pin_pos.split("-")

	hole.pin_position_description = pin_pos.replace("-", " ").capitalize()

	# Determine paces from edges
	match parts[0]:
		"front":
			hole.pin_from_edge = "front"
			hole.pin_paces = randi_range(3, 8)
		"middle":
			hole.pin_from_edge = "front"
			hole.pin_paces = randi_range(12, 18)
		"back":
			hole.pin_from_edge = "back"
			hole.pin_paces = randi_range(4, 8)

	# Adjust total yardage based on pin position
	match parts[0]:
		"front":
			hole.total_yardage -= randi_range(8, 12)
		"back":
			hole.total_yardage += randi_range(5, 10)


static func _generate_bunker_positions(hole_type: Enums.HoleType) -> Array[String]:
	var bunkers: Array[String] = []

	match hole_type:
		Enums.HoleType.PAR_3_SHORT:
			bunkers.append("Front left")
			bunkers.append("Right of green")

		Enums.HoleType.PAR_3_LONG:
			bunkers.append("Front")
			bunkers.append("Left greenside")
			bunkers.append("Right greenside")
			bunkers.append("Back")

		Enums.HoleType.PAR_4_RISK_REWARD:
			bunkers.append("Fairway right")
			bunkers.append("Greenside left")

		Enums.HoleType.PAR_4_POSITIONAL:
			bunkers.append("Fairway left 270")
			bunkers.append("Fairway right 250")
			bunkers.append("Greenside front")
			bunkers.append("Greenside back")

		Enums.HoleType.PAR_5_REACHABLE:
			bunkers.append("Fairway bunker 280")
			bunkers.append("Fairway bunker 310")
			bunkers.append("Greenside left")
			bunkers.append("Greenside right")

	return bunkers


static func _generate_water_position(hole_type: Enums.HoleType) -> String:
	match hole_type:
		Enums.HoleType.PAR_3_SHORT:
			return ["Surrounds green", "Front of green", "Left of green"][randi() % 3]
		Enums.HoleType.PAR_3_LONG:
			return ["Left of green", "Short of green", "Right side"][randi() % 3]
		Enums.HoleType.PAR_4_RISK_REWARD:
			return ["Fronts green", "Left side approach", "Right off tee"][randi() % 3]
		Enums.HoleType.PAR_4_POSITIONAL:
			return ["Left off tee", "Right approach", "Behind green"][randi() % 3]
		Enums.HoleType.PAR_5_REACHABLE:
			return ["Guards green", "Second shot landing area", "Creek crossing"][randi() % 3]

	return "In play"
