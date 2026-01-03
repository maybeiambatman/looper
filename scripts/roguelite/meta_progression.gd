## Handles permanent progression that persists between runs
class_name MetaProgression
extends RefCounted

# XP thresholds for each level
const XP_PER_LEVEL: Array[int] = [
	0,     # Level 1 (starting)
	100,   # Level 2
	250,   # Level 3
	500,   # Level 4
	800,   # Level 5
	1200,  # Level 6
	1700,  # Level 7
	2300,  # Level 8
	3000,  # Level 9
	3800,  # Level 10
	4700,  # Level 11
	5700,  # Level 12
	6800,  # Level 13
	8000,  # Level 14
	9300,  # Level 15
	10700, # Level 16
	12200, # Level 17
	13800, # Level 18
	15500, # Level 19
	17300, # Level 20
	19200, # Level 21
	21200, # Level 22
	23300, # Level 23
	25500, # Level 24
	27800  # Level 25
]

var caddie_level: int = 1
var total_xp: int = 0
var total_runs: int = 0
var wins: int = 0
var losses: int = 0
var highest_run: int = 0
var unlocked_trinkets: Array[String] = []
var permanent_upgrades: Array[String] = []
var statistics: Dictionary = {}


func add_xp(amount: int) -> int:
	"""Add XP and return number of levels gained"""
	var old_level := caddie_level
	total_xp += amount

	# Check for level ups
	while caddie_level < XP_PER_LEVEL.size() and total_xp >= XP_PER_LEVEL[caddie_level]:
		caddie_level += 1
		_on_level_up(caddie_level)

	return caddie_level - old_level


func _on_level_up(new_level: int) -> void:
	"""Handle unlocks when leveling up"""
	match new_level:
		2:
			permanent_upgrades.append("book_front_back")  # Yardage book shows front/back of green
		5:
			permanent_upgrades.append("player_attributes_visible")  # Can see player attributes after 2 holes
		10:
			permanent_upgrades.append("start_with_trinket")  # Start with 1 trinket
		15:
			permanent_upgrades.append("veteran_players")  # Unlock veteran starting players
		20:
			permanent_upgrades.append("additional_courses")  # Unlock additional major courses
		25:
			permanent_upgrades.append("legendary_trinkets")  # Unlock legendary trinkets in pool


func get_xp_for_next_level() -> int:
	if caddie_level >= XP_PER_LEVEL.size():
		return 0
	return XP_PER_LEVEL[caddie_level]


func get_xp_progress() -> float:
	if caddie_level >= XP_PER_LEVEL.size():
		return 1.0

	var current_threshold := XP_PER_LEVEL[caddie_level - 1] if caddie_level > 1 else 0
	var next_threshold := XP_PER_LEVEL[caddie_level]
	var progress := total_xp - current_threshold
	var needed := next_threshold - current_threshold

	return float(progress) / float(needed) if needed > 0 else 1.0


func has_upgrade(upgrade_id: String) -> bool:
	return upgrade_id in permanent_upgrades


func unlock_trinket(trinket_id: String) -> void:
	if trinket_id not in unlocked_trinkets:
		unlocked_trinkets.append(trinket_id)


func is_trinket_unlocked(trinket_id: String) -> bool:
	return trinket_id in unlocked_trinkets


func record_statistic(stat_name: String, value: int = 1) -> void:
	if stat_name in statistics:
		statistics[stat_name] += value
	else:
		statistics[stat_name] = value


func get_statistic(stat_name: String) -> int:
	return statistics.get(stat_name, 0)


func get_win_rate() -> float:
	var total := wins + losses
	return float(wins) / float(total) if total > 0 else 0.0


func to_dict() -> Dictionary:
	return {
		"caddie_level": caddie_level,
		"total_xp": total_xp,
		"total_runs": total_runs,
		"wins": wins,
		"losses": losses,
		"highest_run": highest_run,
		"unlocked_trinkets": unlocked_trinkets,
		"permanent_upgrades": permanent_upgrades,
		"statistics": statistics
	}


static func from_dict(data: Dictionary) -> MetaProgression:
	var meta := MetaProgression.new()
	meta.caddie_level = data.get("caddie_level", 1)
	meta.total_xp = data.get("total_xp", 0)
	meta.total_runs = data.get("total_runs", 0)
	meta.wins = data.get("wins", 0)
	meta.losses = data.get("losses", 0)
	meta.highest_run = data.get("highest_run", 0)
	meta.unlocked_trinkets = data.get("unlocked_trinkets", [])
	meta.permanent_upgrades = data.get("permanent_upgrades", [])
	meta.statistics = data.get("statistics", {})
	return meta
