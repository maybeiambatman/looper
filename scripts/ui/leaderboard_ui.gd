## Leaderboard display UI
extends Control
class_name LeaderboardUI

@onready var leader_name_label: Label = $Panel/LeaderName
@onready var leader_score_label: Label = $Panel/LeaderScore
@onready var player_name_label: Label = $Panel/PlayerName
@onready var player_score_label: Label = $Panel/PlayerScore
@onready var position_label: Label = $Panel/PositionLabel
@onready var holes_remaining_label: Label = $Panel/HolesRemaining


func _ready() -> void:
	if GameManager:
		GameManager.leaderboard_updated.connect(_on_leaderboard_updated)
		GameManager.score_changed.connect(_on_score_changed)


func _on_leaderboard_updated() -> void:
	update_display()


func _on_score_changed(_player_score: int, _leader_score: int) -> void:
	update_display()


func update_display() -> void:
	if not GameManager or not GameManager.tournament:
		return

	var tournament := GameManager.tournament

	# Leader info
	if leader_name_label:
		leader_name_label.text = tournament.leader_name
	if leader_score_label:
		leader_score_label.text = tournament.get_leader_display_score()
		leader_score_label.modulate = Color.WHITE

	# Player info
	if player_name_label and GameManager.player:
		player_name_label.text = GameManager.player.player_name
	if player_score_label:
		player_score_label.text = tournament.get_player_display_score()

		# Color based on position
		if tournament.player_score < tournament.leader_score:
			player_score_label.modulate = Color.GREEN
		elif tournament.player_score == tournament.leader_score:
			player_score_label.modulate = Color.YELLOW
		else:
			player_score_label.modulate = Color.RED

	# Position text
	if position_label:
		position_label.text = tournament.get_position_text()

	# Holes remaining
	if holes_remaining_label:
		holes_remaining_label.text = "%d holes to play" % tournament.holes_remaining


func show_hole_result(hole_number: int, score: int, leader_score: int) -> void:
	"""Show a brief overlay for hole completion"""
	# Create temporary overlay
	var overlay := Panel.new()
	overlay.custom_minimum_size = Vector2(400, 200)
	add_child(overlay)
	overlay.position = get_viewport_rect().size / 2 - overlay.custom_minimum_size / 2

	var vbox := VBoxContainer.new()
	overlay.add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Hole complete text
	var title := Label.new()
	title.text = "HOLE %d COMPLETE" % hole_number
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Player score
	var player_text := Label.new()
	var score_word := _score_to_word(score)
	player_text.text = "Your Player: %s" % score_word
	player_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(player_text)

	# Leader score
	var leader_text := Label.new()
	var leader_word := _score_to_word(leader_score)
	leader_text.text = "Leader: %s" % leader_word
	leader_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(leader_text)

	# Auto-dismiss after delay
	await get_tree().create_timer(3.0).timeout
	overlay.queue_free()

	update_display()


func _score_to_word(score: int) -> String:
	match score:
		-3: return "Albatross!"
		-2: return "Eagle!"
		-1: return "Birdie"
		0: return "Par"
		1: return "Bogey"
		2: return "Double Bogey"
		3: return "Triple Bogey"
		_:
			if score < 0:
				return "%d under" % abs(score)
			else:
				return "+%d" % score
