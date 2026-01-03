## Resource class holding a golfer's attributes and derived stats
class_name GolferAttributes
extends Resource

@export var player_name: String = "Player"
@export var player_personality: String = "Steady player, plays it safe"
@export var power: int = 12        # 1-20: Affects distance
@export var accuracy: int = 12     # 1-20: Baseline dispersion
@export var iron_play: int = 12    # 1-20: Approach shot proficiency
@export var short_game: int = 12   # 1-20: Inside 100 yards
@export var putting: int = 12      # 1-20: Green reading and stroke
@export var clutch: int = 12       # 1-20: Performance under pressure
@export var consistency: int = 12  # 1-20: Variance in performance
@export var recovery: int = 12     # 1-20: Ability from bad lies

# Tendencies (hidden from player initially)
@export var miss_tendency: String = "straight"  # "left", "right", "straight"
@export var pressure_tendency: String = "neutral"  # "choke", "neutral", "clutch"

# Derived: club distances calculated from power
var club_distances: Dictionary = {}


func _init() -> void:
	calculate_club_distances()


func calculate_club_distances() -> void:
	# Base distances at power 10, scale up/down
	# power 1 = 0.82x, power 20 = 1.2x
	var power_multiplier: float = 0.8 + (power * 0.02)

	club_distances = {
		"driver": int(270 * power_multiplier),
		"3_wood": int(245 * power_multiplier),
		"5_wood": int(230 * power_multiplier),
		"hybrid": int(215 * power_multiplier),
		"4_iron": int(200 * power_multiplier),
		"5_iron": int(190 * power_multiplier),
		"6_iron": int(180 * power_multiplier),
		"7_iron": int(170 * power_multiplier),
		"8_iron": int(160 * power_multiplier),
		"9_iron": int(150 * power_multiplier),
		"pw": int(140 * power_multiplier),
		"gw": int(125 * power_multiplier),
		"sw": int(110 * power_multiplier),
		"lw": int(90 * power_multiplier),
		"putter": 0  # Putting doesn't use distance the same way
	}


func get_club_distance(club: String) -> int:
	if club_distances.is_empty():
		calculate_club_distances()
	return club_distances.get(club, 150)


func get_best_club_for_distance(target_distance: float) -> String:
	"""Returns the club that best matches the target distance"""
	if club_distances.is_empty():
		calculate_club_distances()

	var best_club := "7_iron"
	var best_diff := 9999.0

	for club_name in club_distances:
		if club_name == "putter":
			continue
		var club_dist: int = int(club_distances[club_name])
		var diff: float = absf(float(club_dist) - target_distance)
		if diff < best_diff:
			best_diff = diff
			best_club = club_name

	return best_club


func get_all_clubs() -> Array[String]:
	return [
		"driver", "3_wood", "5_wood", "hybrid",
		"4_iron", "5_iron", "6_iron", "7_iron", "8_iron", "9_iron",
		"pw", "gw", "sw", "lw", "putter"
	]


func get_total_rating() -> int:
	return power + accuracy + iron_play + short_game + putting + clutch + consistency + recovery


func get_average_rating() -> float:
	return get_total_rating() / 8.0


func get_strength_description() -> String:
	var max_stat := power
	var strength := "power"

	if accuracy > max_stat:
		max_stat = accuracy
		strength = "accuracy"
	if iron_play > max_stat:
		max_stat = iron_play
		strength = "iron play"
	if short_game > max_stat:
		max_stat = short_game
		strength = "short game"
	if putting > max_stat:
		max_stat = putting
		strength = "putting"

	return strength


func get_weakness_description() -> String:
	var min_stat := power
	var weakness := "power"

	if accuracy < min_stat:
		min_stat = accuracy
		weakness = "accuracy"
	if iron_play < min_stat:
		min_stat = iron_play
		weakness = "iron play"
	if short_game < min_stat:
		min_stat = short_game
		weakness = "short game"
	if putting < min_stat:
		min_stat = putting
		weakness = "putting"

	return weakness


func apply_trinket_effect(effect_type: Enums.TrinketEffectType, value: float) -> void:
	match effect_type:
		Enums.TrinketEffectType.POWER_BOOST:
			power = mini(20, power + int(value))
			calculate_club_distances()
		Enums.TrinketEffectType.ACCURACY_BOOST:
			accuracy = mini(20, accuracy + int(value))
		Enums.TrinketEffectType.SHORT_GAME_BOOST:
			short_game = mini(20, short_game + int(value))
		Enums.TrinketEffectType.PUTTING_BOOST:
			putting = mini(20, putting + int(value))
		Enums.TrinketEffectType.CLUTCH_BOOST:
			clutch = mini(20, clutch + int(value))
		Enums.TrinketEffectType.CONSISTENCY_BOOST:
			consistency = mini(20, consistency + int(value))
		Enums.TrinketEffectType.RECOVERY_BOOST:
			recovery = mini(20, recovery + int(value))
		Enums.TrinketEffectType.IRON_PLAY_BOOST:
			iron_play = mini(20, iron_play + int(value))


func to_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"player_personality": player_personality,
		"power": power,
		"accuracy": accuracy,
		"iron_play": iron_play,
		"short_game": short_game,
		"putting": putting,
		"clutch": clutch,
		"consistency": consistency,
		"recovery": recovery,
		"miss_tendency": miss_tendency,
		"pressure_tendency": pressure_tendency
	}


static func from_dict(data: Dictionary) -> GolferAttributes:
	var attrs := GolferAttributes.new()
	attrs.player_name = data.get("player_name", "Player")
	attrs.player_personality = data.get("player_personality", "")
	attrs.power = data.get("power", 12)
	attrs.accuracy = data.get("accuracy", 12)
	attrs.iron_play = data.get("iron_play", 12)
	attrs.short_game = data.get("short_game", 12)
	attrs.putting = data.get("putting", 12)
	attrs.clutch = data.get("clutch", 12)
	attrs.consistency = data.get("consistency", 12)
	attrs.recovery = data.get("recovery", 12)
	attrs.miss_tendency = data.get("miss_tendency", "straight")
	attrs.pressure_tendency = data.get("pressure_tendency", "neutral")
	attrs.calculate_club_distances()
	return attrs
