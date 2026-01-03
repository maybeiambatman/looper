## Data class containing all information about a single run
class_name RunData
extends RefCounted

var run_number: int = 1
var difficulty: int = 1
var current_hole: int = 0
var hole_scores: Array[int] = []
var shots_taken: int = 0
var good_decisions: int = 0
var bad_decisions: int = 0
var holes: Array = []  # Array of HoleData
var active_trinkets: Array = []  # Array of Trinket
var won: bool = false
var timestamp: int = 0


func get_total_score() -> int:
	var total := 0
	for score in hole_scores:
		total += score
	return total


func get_score_to_par() -> int:
	return get_total_score()


func get_score_display() -> String:
	var score := get_score_to_par()
	if score == 0:
		return "E"
	elif score > 0:
		return "+%d" % score
	else:
		return "%d" % score


func is_complete() -> bool:
	return hole_scores.size() >= 5


func get_current_hole_number() -> int:
	return current_hole + 14  # Holes 14-18


func to_dict() -> Dictionary:
	var trinket_ids: Array[String] = []
	for trinket in active_trinkets:
		if trinket and trinket.has_method("get_id"):
			trinket_ids.append(trinket.get_id())

	return {
		"run_number": run_number,
		"difficulty": difficulty,
		"current_hole": current_hole,
		"hole_scores": hole_scores,
		"shots_taken": shots_taken,
		"good_decisions": good_decisions,
		"bad_decisions": bad_decisions,
		"won": won,
		"timestamp": timestamp,
		"trinket_ids": trinket_ids
	}


static func from_dict(data: Dictionary) -> RunData:
	var run := RunData.new()
	run.run_number = data.get("run_number", 1)
	run.difficulty = data.get("difficulty", 1)
	run.current_hole = data.get("current_hole", 0)
	run.hole_scores = data.get("hole_scores", [])
	run.shots_taken = data.get("shots_taken", 0)
	run.good_decisions = data.get("good_decisions", 0)
	run.bad_decisions = data.get("bad_decisions", 0)
	run.won = data.get("won", false)
	run.timestamp = data.get("timestamp", 0)
	return run
