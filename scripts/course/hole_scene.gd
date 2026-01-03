## Base script for hole scenes
extends Node3D
class_name HoleScene

@export var hole_data: HoleData = null

# References to key nodes
@onready var terrain: Node3D = $Terrain
@onready var hazards: Node3D = $Hazards
@onready var flag: Node3D = $Flag

# Collision areas for lie detection
var green_area: Area3D = null
var fairway_area: Area3D = null
var rough_area: Area3D = null
var bunker_areas: Array[Area3D] = []
var water_areas: Array[Area3D] = []


func _ready() -> void:
	_setup_collision_areas()


func configure(data: HoleData) -> void:
	"""Configure the hole with specific data"""
	hole_data = data

	# Move pin to correct position if specified
	if flag and data.pin_position != Vector3.ZERO:
		flag.global_position = data.pin_position


func _setup_collision_areas() -> void:
	"""Setup collision detection areas for different terrain types"""
	# In a full implementation, these would be set up based on the actual
	# geometry of the hole. For now, we use simple detection.
	pass


func get_lie_at_position(world_position: Vector3) -> Enums.LieType:
	"""Determine the lie type at a given world position"""
	# Simple distance-based detection for prototype
	# In full implementation, would use Area3D collision detection

	if not hole_data:
		return Enums.LieType.FAIRWAY

	# Check if on green (near pin)
	var dist_to_pin := world_position.distance_to(hole_data.pin_position)
	if dist_to_pin < 20:  # Rough green radius
		return Enums.LieType.GREEN

	# Check fringe
	if dist_to_pin < 25:
		return Enums.LieType.FRINGE

	# Check for bunkers (simplified)
	for bunker in hazards.get_children():
		if bunker is CSGShape3D:
			var dist := world_position.distance_to(bunker.global_position)
			if dist < 6:  # Bunker radius
				if dist_to_pin < 50:
					return Enums.LieType.GREENSIDE_BUNKER
				else:
					return Enums.LieType.FAIRWAY_BUNKER

	# Check for water
	if hole_data.has_water:
		# Simplified water check
		var water_node := terrain.get_node_or_null("Water")
		if water_node:
			var dist := world_position.distance_to(water_node.global_position)
			if dist < 40 and world_position.y < 0:
				return Enums.LieType.WATER

	# Check for fairway vs rough based on x position
	if abs(world_position.x) < 15:
		return Enums.LieType.FAIRWAY
	elif abs(world_position.x) < 25:
		return Enums.LieType.LIGHT_ROUGH
	else:
		return Enums.LieType.HEAVY_ROUGH


func get_distance_to_pin(from_position: Vector3) -> float:
	"""Get distance to pin in yards"""
	if not hole_data:
		return 0.0
	return from_position.distance_to(hole_data.pin_position) * 1.09361  # meters to yards


func get_pin_position() -> Vector3:
	if flag:
		return flag.global_position
	elif hole_data:
		return hole_data.pin_position
	return Vector3.ZERO


func get_tee_position() -> Vector3:
	if hole_data:
		return hole_data.tee_position
	return Vector3.ZERO
