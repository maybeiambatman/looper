## Manages the trinket database and trinket-related operations
extends Node

# All available trinkets indexed by ID
var _trinkets: Dictionary = {}

# Rarity weights for random selection
const RARITY_WEIGHTS := {
	Enums.TrinketRarity.COMMON: 60,
	Enums.TrinketRarity.UNCOMMON: 25,
	Enums.TrinketRarity.RARE: 12,
	Enums.TrinketRarity.LEGENDARY: 3
}


func _ready() -> void:
	_initialize_trinkets()


func _initialize_trinkets() -> void:
	"""Create all trinket definitions"""

	# === CADDIE TRINKETS ===

	_add_trinket(Trinket.new(), {
		"id": "wind_sense",
		"name": "Wind Sense",
		"description": "Years on the coast taught you the wind. Wind indicator becomes more precise.",
		"flavor_text": "The flags don't lie.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.CADDIE,
		"effect_type": Enums.TrinketEffectType.WIND_SENSE,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "yardage_intuition",
		"name": "Yardage Intuition",
		"description": "You can feel distances in your bones. Subtle distance hints appear.",
		"flavor_text": "That's a hard 7, trust me.",
		"rarity": Enums.TrinketRarity.UNCOMMON,
		"trinket_type": Enums.TrinketType.CADDIE,
		"effect_type": Enums.TrinketEffectType.YARDAGE_HINT,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "green_readers_eye",
		"name": "Green Reader's Eye",
		"description": "You see breaks others miss. Subtle arrow hints on severe slopes.",
		"flavor_text": "It's more than it looks.",
		"rarity": Enums.TrinketRarity.UNCOMMON,
		"trinket_type": Enums.TrinketType.CADDIE,
		"effect_type": Enums.TrinketEffectType.GREEN_READ_HINT,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "temperature_gauge",
		"name": "Temperature Gauge",
		"description": "You know how the air affects the ball. Temperature adjustment suggestions appear.",
		"flavor_text": "Ball's flying today.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.CADDIE,
		"effect_type": Enums.TrinketEffectType.TEMPERATURE_HINT,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "caddies_calm",
		"name": "Caddie's Calm",
		"description": "Your composure settles the player. Reduce pressure penalty by 15%.",
		"flavor_text": "We've got this.",
		"rarity": Enums.TrinketRarity.RARE,
		"trinket_type": Enums.TrinketType.CADDIE,
		"effect_type": Enums.TrinketEffectType.PRESSURE_REDUCTION,
		"effect_value": 0.15
	})

	_add_trinket(Trinket.new(), {
		"id": "book_mastery",
		"name": "Book Mastery",
		"description": "You've memorized every inch. Yardage book shows more precise numbers.",
		"flavor_text": "Page 47, paragraph 3.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.CADDIE,
		"effect_type": Enums.TrinketEffectType.BOOK_PRECISION,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "loopers_intuition",
		"name": "Looper's Intuition",
		"description": "You sense when they're feeling it. Player confidence indicator appears.",
		"flavor_text": "He's got that look.",
		"rarity": Enums.TrinketRarity.UNCOMMON,
		"trinket_type": Enums.TrinketType.CADDIE,
		"effect_type": Enums.TrinketEffectType.CONFIDENCE_INDICATOR,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "veterans_wisdom",
		"name": "Veteran's Wisdom",
		"description": "You've seen every lie. Lie assessment becomes more detailed.",
		"flavor_text": "I've seen worse. Much worse.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.CADDIE,
		"effect_type": Enums.TrinketEffectType.LIE_DETAIL,
		"effect_value": 1.0
	})

	# === PLAYER TRINKETS ===

	_add_trinket(Trinket.new(), {
		"id": "driving_range_hours",
		"name": "Driving Range Hours",
		"description": "They've been grinding. +1 to Accuracy.",
		"flavor_text": "Three buckets a day.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.PLAYER,
		"effect_type": Enums.TrinketEffectType.ACCURACY_BOOST,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "strength_training",
		"name": "Strength Training",
		"description": "Added 10 yards off the tee. +1 to Power.",
		"flavor_text": "Gym time pays off.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.PLAYER,
		"effect_type": Enums.TrinketEffectType.POWER_BOOST,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "short_game_session",
		"name": "Short Game Session",
		"description": "Phil gave them tips. +1 to Short Game.",
		"flavor_text": "Flop it like it's hot.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.PLAYER,
		"effect_type": Enums.TrinketEffectType.SHORT_GAME_BOOST,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "putting_clinic",
		"name": "Putting Clinic",
		"description": "Stroke is pure. +1 to Putting.",
		"flavor_text": "See it, roll it, hole it.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.PLAYER,
		"effect_type": Enums.TrinketEffectType.PUTTING_BOOST,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "mental_coach",
		"name": "Mental Coach",
		"description": "They're seeing a sports psychologist. +1 to Clutch.",
		"flavor_text": "Breathe. Focus. Execute.",
		"rarity": Enums.TrinketRarity.UNCOMMON,
		"trinket_type": Enums.TrinketType.PLAYER,
		"effect_type": Enums.TrinketEffectType.CLUTCH_BOOST,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "course_management",
		"name": "Course Management",
		"description": "They trust the process now. +1 to Consistency.",
		"flavor_text": "No hero shots today.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.PLAYER,
		"effect_type": Enums.TrinketEffectType.CONSISTENCY_BOOST,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "recovery_specialist",
		"name": "Recovery Specialist",
		"description": "They've practiced from the trees. +1 to Recovery.",
		"flavor_text": "Bubba would be proud.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.PLAYER,
		"effect_type": Enums.TrinketEffectType.RECOVERY_BOOST,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "iron_precision",
		"name": "Iron Precision",
		"description": "Pure ball striker. +1 to Iron Play.",
		"flavor_text": "Compressed to perfection.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.PLAYER,
		"effect_type": Enums.TrinketEffectType.IRON_PLAY_BOOST,
		"effect_value": 1.0
	})

	# === SITUATIONAL TRINKETS ===

	_add_trinket(Trinket.new(), {
		"id": "mulligan_ticket",
		"name": "Mulligan Ticket",
		"description": "One do-over per round. Can re-do one shot recommendation.",
		"flavor_text": "Everybody gets one.",
		"rarity": Enums.TrinketRarity.RARE,
		"trinket_type": Enums.TrinketType.SITUATIONAL,
		"effect_type": Enums.TrinketEffectType.MULLIGAN,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "leaders_curse",
		"name": "Leader's Curse",
		"description": "The pressure gets to them too. Leader more likely to make mistakes.",
		"flavor_text": "Heavy is the head...",
		"rarity": Enums.TrinketRarity.RARE,
		"trinket_type": Enums.TrinketType.SITUATIONAL,
		"effect_type": Enums.TrinketEffectType.LEADER_PRESSURE,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "hometown_crowd",
		"name": "Hometown Crowd",
		"description": "The gallery loves your player. Good shots get extra momentum boost.",
		"flavor_text": "Listen to that roar!",
		"rarity": Enums.TrinketRarity.UNCOMMON,
		"trinket_type": Enums.TrinketType.SITUATIONAL,
		"effect_type": Enums.TrinketEffectType.CROWD_BOOST,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "favorable_conditions",
		"name": "Favorable Conditions",
		"description": "The golf gods smile. Slightly easier starting conditions.",
		"flavor_text": "Perfect day for golf.",
		"rarity": Enums.TrinketRarity.COMMON,
		"trinket_type": Enums.TrinketType.SITUATIONAL,
		"effect_type": Enums.TrinketEffectType.FAVORABLE_CONDITIONS,
		"effect_value": 1.0
	})

	_add_trinket(Trinket.new(), {
		"id": "second_look",
		"name": "Second Look",
		"description": "Trust but verify. See predicted outcome range before confirming shot.",
		"flavor_text": "Let me think about this...",
		"rarity": Enums.TrinketRarity.LEGENDARY,
		"trinket_type": Enums.TrinketType.SITUATIONAL,
		"effect_type": Enums.TrinketEffectType.OUTCOME_PREVIEW,
		"effect_value": 1.0
	})

	# === LEGENDARY TRINKETS ===

	_add_trinket(Trinket.new(), {
		"id": "major_champion_aura",
		"name": "Major Champion Aura",
		"description": "They've won before. They'll win again. +2 to Clutch, reduced pressure.",
		"flavor_text": "This is what champions do.",
		"rarity": Enums.TrinketRarity.LEGENDARY,
		"trinket_type": Enums.TrinketType.PLAYER,
		"effect_type": Enums.TrinketEffectType.CLUTCH_BOOST,
		"effect_value": 2.0
	})

	_add_trinket(Trinket.new(), {
		"id": "caddie_of_legends",
		"name": "Caddie of Legends",
		"description": "You've carried for the greats. All caddie bonuses enhanced.",
		"flavor_text": "Tiger's bag felt heavier.",
		"rarity": Enums.TrinketRarity.LEGENDARY,
		"trinket_type": Enums.TrinketType.CADDIE,
		"effect_type": Enums.TrinketEffectType.WIND_SENSE,
		"effect_value": 2.0
	})


func _add_trinket(trinket: Trinket, data: Dictionary) -> void:
	trinket.id = data.get("id", "")
	trinket.name = data.get("name", "")
	trinket.description = data.get("description", "")
	trinket.flavor_text = data.get("flavor_text", "")
	trinket.rarity = data.get("rarity", Enums.TrinketRarity.COMMON)
	trinket.trinket_type = data.get("trinket_type", Enums.TrinketType.CADDIE)
	trinket.effect_type = data.get("effect_type", Enums.TrinketEffectType.WIND_SENSE)
	trinket.effect_value = data.get("effect_value", 1.0)
	_trinkets[trinket.id] = trinket


func get_trinket(trinket_id: String) -> Trinket:
	return _trinkets.get(trinket_id, null)


func get_all_trinkets() -> Array[Trinket]:
	var trinkets: Array[Trinket] = []
	for trinket in _trinkets.values():
		trinkets.append(trinket)
	return trinkets


func get_trinkets_by_rarity(rarity: Enums.TrinketRarity) -> Array[Trinket]:
	var result: Array[Trinket] = []
	for trinket in _trinkets.values():
		if trinket.rarity == rarity:
			result.append(trinket)
	return result


func get_trinkets_by_type(type: Enums.TrinketType) -> Array[Trinket]:
	var result: Array[Trinket] = []
	for trinket in _trinkets.values():
		if trinket.trinket_type == type:
			result.append(trinket)
	return result


func get_random_trinkets(count: int, exclude: Array = [], include_legendary: bool = true) -> Array[Trinket]:
	"""Get random trinkets with rarity weighting"""
	var available: Array[Trinket] = []

	for trinket in _trinkets.values():
		if trinket.id in exclude:
			continue
		if not include_legendary and trinket.rarity == Enums.TrinketRarity.LEGENDARY:
			continue
		available.append(trinket)

	if available.size() <= count:
		return available

	var result: Array[Trinket] = []
	var attempts := 0
	var max_attempts := count * 10

	while result.size() < count and attempts < max_attempts:
		attempts += 1
		var trinket := _select_weighted_random(available)
		if trinket and trinket not in result:
			result.append(trinket)

	return result


func _select_weighted_random(pool: Array[Trinket]) -> Trinket:
	"""Select a trinket using rarity weights"""
	if pool.is_empty():
		return null

	var total_weight := 0
	for trinket in pool:
		total_weight += RARITY_WEIGHTS.get(trinket.rarity, 10)

	var roll := randi() % total_weight
	var current_weight := 0

	for trinket in pool:
		current_weight += RARITY_WEIGHTS.get(trinket.rarity, 10)
		if roll < current_weight:
			return trinket

	return pool[0]


func has_trinket_effect(trinkets: Array, effect_type: Enums.TrinketEffectType) -> bool:
	"""Check if any trinket in the array has the specified effect"""
	for trinket in trinkets:
		if trinket and trinket.effect_type == effect_type:
			return true
	return false


func get_trinket_effect_value(trinkets: Array, effect_type: Enums.TrinketEffectType) -> float:
	"""Get the total effect value for an effect type from all trinkets"""
	var total := 0.0
	for trinket in trinkets:
		if trinket and trinket.effect_type == effect_type:
			total += trinket.effect_value
	return total
