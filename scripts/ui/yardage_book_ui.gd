## Yardage book UI component
extends Control
class_name YardageBookUI

# UI References
@onready var hole_name_label: Label = $BookPanel/LeftPage/HoleName
@onready var hole_info_label: Label = $BookPanel/LeftPage/HoleInfo
@onready var yardages_container: VBoxContainer = $BookPanel/LeftPage/Yardages
@onready var pin_info_label: Label = $BookPanel/RightPage/PinInfo
@onready var notes_label: Label = $BookPanel/RightPage/Notes
@onready var green_info_label: Label = $BookPanel/RightPage/GreenInfo

var current_hole_data: HoleData = null


func _ready() -> void:
	visible = false


func show_hole(hole_data: HoleData) -> void:
	current_hole_data = hole_data

	# Set hole info
	if hole_name_label:
		hole_name_label.text = "HOLE %d - PAR %d" % [hole_data.hole_number, hole_data.par]

	if hole_info_label:
		hole_info_label.text = "%d YARDS" % hole_data.total_yardage

	# Clear and populate yardages
	if yardages_container:
		for child in yardages_container.get_children():
			child.queue_free()

		for landmark in hole_data.landmarks:
			var label := Label.new()
			label.text = "%s: %d yards" % [landmark.get("name", ""), landmark.get("yardage", 0)]
			label.add_theme_font_size_override("font_size", 14)
			yardages_container.add_child(label)

	# Pin position
	if pin_info_label:
		pin_info_label.text = "PIN: %s\n%d paces from %s edge" % [
			hole_data.pin_position_description,
			hole_data.pin_paces,
			hole_data.pin_from_edge
		]

	# Caddie notes
	if notes_label:
		notes_label.text = hole_data.caddie_notes

	# Green info
	if green_info_label:
		green_info_label.text = "Green: %d yards deep\n%s slope\nSpeed: %s" % [
			hole_data.green_depth,
			hole_data.green_slope_description,
			hole_data.green_speed
		]


func _input(event: InputEvent) -> void:
	if not visible:
		return

	# Could add page flip functionality here
	if event.is_action_pressed("book_next_page"):
		# Show next page
		pass
	elif event.is_action_pressed("book_prev_page"):
		# Show previous page
		pass
