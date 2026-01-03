## Tracks the current tournament state including scores and positions
class_name TournamentState
extends RefCounted

var leader_score: int = -10  # Score relative to par (negative is good)
var player_score: int = -9   # Player starts 1+ shots back
var holes_remaining: int = 5
var leader_name: String = "Tournament Leader"
var leader_attributes: GolferAttributes = null

# Hole-by-hole tracking
var leader_hole_scores: Array[int] = []
var player_hole_scores: Array[int] = []

# Current pressure situation
var current_pressure: Enums.PressureLevel = Enums.PressureLevel.CLOSE


func get_deficit() -> int:
	"""Returns how many shots the player trails by (positive = trailing)"""
	return player_score - leader_score


func get_position_text() -> String:
	var deficit := get_deficit()
	if deficit < 0:
		return "Leading by %d" % abs(deficit)
	elif deficit == 0:
		return "Tied for the lead"
	else:
		return "%d back" % deficit


func get_leader_display_score() -> String:
	if leader_score == 0:
		return "E"
	elif leader_score > 0:
		return "+%d" % leader_score
	else:
		return "%d" % leader_score


func get_player_display_score() -> String:
	if player_score == 0:
		return "E"
	elif player_score > 0:
		return "+%d" % player_score
	else:
		return "%d" % player_score


func update_pressure() -> void:
	"""Calculate current pressure level based on situation"""
	var deficit := get_deficit()

	if holes_remaining == 1:
		# Final hole
		if deficit >= 2:
			current_pressure = Enums.PressureLevel.WIN_OR_LOSE
		elif deficit == 1:
			current_pressure = Enums.PressureLevel.MUST_PERFORM
		elif deficit == 0:
			current_pressure = Enums.PressureLevel.WIN_OR_LOSE
		else:
			current_pressure = Enums.PressureLevel.CLOSE
	elif holes_remaining == 2:
		# Two holes left
		if deficit >= 3:
			current_pressure = Enums.PressureLevel.WIN_OR_LOSE
		elif deficit >= 1:
			current_pressure = Enums.PressureLevel.MUST_PERFORM
		else:
			current_pressure = Enums.PressureLevel.CLOSE
	else:
		# Earlier holes
		if deficit >= 4:
			current_pressure = Enums.PressureLevel.MUST_PERFORM
		elif deficit >= 2:
			current_pressure = Enums.PressureLevel.CLOSE
		elif deficit < 0:
			current_pressure = Enums.PressureLevel.COMFORTABLE
		else:
			current_pressure = Enums.PressureLevel.CLOSE


func get_pressure_level() -> Enums.PressureLevel:
	update_pressure()
	return current_pressure


func is_player_leading() -> bool:
	return player_score < leader_score


func is_tied() -> bool:
	return player_score == leader_score


func record_player_hole(score_to_par: int) -> void:
	player_hole_scores.append(score_to_par)
	player_score += score_to_par
	holes_remaining -= 1
	update_pressure()


func record_leader_hole(score_to_par: int) -> void:
	leader_hole_scores.append(score_to_par)
	leader_score += score_to_par


func is_tournament_over() -> bool:
	return holes_remaining <= 0


func did_player_win() -> bool:
	return player_score < leader_score


func is_playoff() -> bool:
	return player_score == leader_score and holes_remaining <= 0


func to_dict() -> Dictionary:
	return {
		"leader_score": leader_score,
		"player_score": player_score,
		"holes_remaining": holes_remaining,
		"leader_name": leader_name,
		"leader_hole_scores": leader_hole_scores,
		"player_hole_scores": player_hole_scores
	}


static func from_dict(data: Dictionary) -> TournamentState:
	var state := TournamentState.new()
	state.leader_score = data.get("leader_score", -10)
	state.player_score = data.get("player_score", -9)
	state.holes_remaining = data.get("holes_remaining", 5)
	state.leader_name = data.get("leader_name", "Tournament Leader")
	state.leader_hole_scores = data.get("leader_hole_scores", [])
	state.player_hole_scores = data.get("player_hole_scores", [])
	state.update_pressure()
	return state
