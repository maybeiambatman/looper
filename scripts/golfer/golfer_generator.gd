## Generates random golfer profiles
class_name GolferGenerator
extends RefCounted

# Name pools
const FIRST_NAMES: Array[String] = [
	"Jack", "Tiger", "Phil", "Rory", "Jordan", "Brooks", "Dustin", "Justin",
	"Patrick", "Xander", "Collin", "Viktor", "Jon", "Scottie", "Cameron",
	"Tommy", "Max", "Matt", "Sam", "Rickie", "Jason", "Bubba", "Adam",
	"Henrik", "Sergio", "Ernie", "Fred", "Davis", "Bryson", "Tony"
]

const LAST_NAMES: Array[String] = [
	"Palmer", "Woods", "Nicklaus", "Watson", "Player", "Hogan", "Snead",
	"McIlroy", "Spieth", "Johnson", "Thomas", "Koepka", "Reed", "Finau",
	"Rose", "Garcia", "Fowler", "Scott", "Day", "Rahm", "Scheffler",
	"Morikawa", "Hovland", "Burns", "Cantlay", "Matsuyama", "Fleetwood",
	"Casey", "Lowry", "Hatton"
]

const PERSONALITIES: Array[String] = [
	"Aggressive player, likes to go for it",
	"Steady and conservative, rarely makes mistakes",
	"Streaky player, can get hot or cold",
	"Great front-runner, struggles when chasing",
	"Thrives under pressure, loves the big stage",
	"Patient player, waits for opportunities",
	"Bomber off the tee, sometimes wild",
	"Precision player, not long but accurate",
	"Short game wizard, always gets up and down",
	"Ice cold putter, rarely misses inside 10 feet",
	"Course management specialist",
	"Emotional player, wears heart on sleeve",
	"Quiet confidence, unflappable demeanor",
	"Crowd favorite, feeds off the energy",
	"Grinder, never gives up"
]

const MISS_TENDENCIES: Array[String] = ["left", "right", "straight"]
const PRESSURE_TENDENCIES: Array[String] = ["choke", "neutral", "clutch"]


static func generate_player(difficulty: int = 1, trinkets: Array = []) -> GolferAttributes:
	var player := GolferAttributes.new()

	# Generate name
	player.player_name = _generate_name()
	player.player_personality = PERSONALITIES[randi() % PERSONALITIES.size()]

	# Base stat range depends on difficulty
	# Higher difficulty = potentially weaker players (more variance)
	var base_min := 10 - (difficulty - 1)
	var base_max := 16 - (difficulty - 1) / 2
	base_min = clampi(base_min, 6, 12)
	base_max = clampi(base_max, 12, 18)

	# Generate stats with some variance
	player.power = randi_range(base_min, base_max)
	player.accuracy = randi_range(base_min, base_max)
	player.iron_play = randi_range(base_min, base_max)
	player.short_game = randi_range(base_min, base_max)
	player.putting = randi_range(base_min, base_max)
	player.clutch = randi_range(base_min, base_max)
	player.consistency = randi_range(base_min, base_max)
	player.recovery = randi_range(base_min, base_max)

	# Add some character - one strength and one weakness
	_add_specialization(player)

	# Hidden tendencies
	player.miss_tendency = MISS_TENDENCIES[randi() % MISS_TENDENCIES.size()]
	player.pressure_tendency = PRESSURE_TENDENCIES[randi() % PRESSURE_TENDENCIES.size()]

	# Apply veteran bonus if trinkets include it
	for trinket in trinkets:
		if trinket and trinket.effect_type == Enums.TrinketEffectType.POWER_BOOST:
			player.apply_trinket_effect(trinket.effect_type, trinket.effect_value)

	player.calculate_club_distances()
	return player


static func generate_veteran_player() -> GolferAttributes:
	"""Generate a higher-rated player for later unlocks"""
	var player := GolferAttributes.new()

	player.player_name = _generate_name()
	player.player_personality = PERSONALITIES[randi() % PERSONALITIES.size()]

	# Veterans have higher base stats
	var base_min := 12
	var base_max := 18

	player.power = randi_range(base_min, base_max)
	player.accuracy = randi_range(base_min, base_max)
	player.iron_play = randi_range(base_min, base_max)
	player.short_game = randi_range(base_min, base_max)
	player.putting = randi_range(base_min, base_max)
	player.clutch = randi_range(base_min + 2, base_max)  # Veterans are clutch
	player.consistency = randi_range(base_min, base_max)
	player.recovery = randi_range(base_min, base_max)

	player.miss_tendency = MISS_TENDENCIES[randi() % MISS_TENDENCIES.size()]
	player.pressure_tendency = "clutch" if randf() > 0.5 else "neutral"

	player.calculate_club_distances()
	return player


static func generate_leader(difficulty: int = 1) -> GolferAttributes:
	"""Generate the tournament leader AI's attributes"""
	var leader := GolferAttributes.new()

	leader.player_name = _generate_name()
	leader.player_personality = "Tournament leader"

	# Leader is generally strong but affected by difficulty
	var base_min := 12 + difficulty
	var base_max := 16 + difficulty
	base_min = clampi(base_min, 12, 16)
	base_max = clampi(base_max, 16, 20)

	leader.power = randi_range(base_min, base_max)
	leader.accuracy = randi_range(base_min, base_max)
	leader.iron_play = randi_range(base_min, base_max)
	leader.short_game = randi_range(base_min, base_max)
	leader.putting = randi_range(base_min, base_max)
	leader.clutch = randi_range(base_min - 2, base_max)  # Variable clutch
	leader.consistency = randi_range(base_min, base_max)
	leader.recovery = randi_range(base_min, base_max)

	leader.miss_tendency = MISS_TENDENCIES[randi() % MISS_TENDENCIES.size()]
	leader.pressure_tendency = ["neutral", "clutch", "choke"][randi() % 3]

	leader.calculate_club_distances()
	return leader


static func _generate_name() -> String:
	var first := FIRST_NAMES[randi() % FIRST_NAMES.size()]
	var last := LAST_NAMES[randi() % LAST_NAMES.size()]
	return first + " " + last


static func _add_specialization(player: GolferAttributes) -> void:
	"""Add one strength (+2-3) and one weakness (-2-3) to make players unique"""
	var stats := ["power", "accuracy", "iron_play", "short_game", "putting", "clutch", "consistency", "recovery"]
	stats.shuffle()

	var strength_stat: String = stats[0]
	var weakness_stat: String = stats[1]

	var strength_bonus := randi_range(2, 3)
	var weakness_penalty := randi_range(2, 3)

	match strength_stat:
		"power": player.power = mini(20, player.power + strength_bonus)
		"accuracy": player.accuracy = mini(20, player.accuracy + strength_bonus)
		"iron_play": player.iron_play = mini(20, player.iron_play + strength_bonus)
		"short_game": player.short_game = mini(20, player.short_game + strength_bonus)
		"putting": player.putting = mini(20, player.putting + strength_bonus)
		"clutch": player.clutch = mini(20, player.clutch + strength_bonus)
		"consistency": player.consistency = mini(20, player.consistency + strength_bonus)
		"recovery": player.recovery = mini(20, player.recovery + strength_bonus)

	match weakness_stat:
		"power": player.power = maxi(1, player.power - weakness_penalty)
		"accuracy": player.accuracy = maxi(1, player.accuracy - weakness_penalty)
		"iron_play": player.iron_play = maxi(1, player.iron_play - weakness_penalty)
		"short_game": player.short_game = maxi(1, player.short_game - weakness_penalty)
		"putting": player.putting = maxi(1, player.putting - weakness_penalty)
		"clutch": player.clutch = maxi(1, player.clutch - weakness_penalty)
		"consistency": player.consistency = maxi(1, player.consistency - weakness_penalty)
		"recovery": player.recovery = maxi(1, player.recovery - weakness_penalty)
