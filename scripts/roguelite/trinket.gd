## Resource class representing a roguelite trinket/upgrade
class_name Trinket
extends Resource

@export var id: String = ""
@export var name: String = ""
@export_multiline var description: String = ""
@export var flavor_text: String = ""
@export var rarity: Enums.TrinketRarity = Enums.TrinketRarity.COMMON
@export var trinket_type: Enums.TrinketType = Enums.TrinketType.CADDIE
@export var effect_type: Enums.TrinketEffectType = Enums.TrinketEffectType.WIND_SENSE
@export var effect_value: float = 1.0
@export var icon: Texture2D = null


func get_id() -> String:
	return id


func get_rarity_color() -> Color:
	return Enums.get_rarity_color(rarity)


func get_rarity_name() -> String:
	match rarity:
		Enums.TrinketRarity.COMMON:
			return "Common"
		Enums.TrinketRarity.UNCOMMON:
			return "Uncommon"
		Enums.TrinketRarity.RARE:
			return "Rare"
		Enums.TrinketRarity.LEGENDARY:
			return "Legendary"
	return "Unknown"


func get_type_name() -> String:
	match trinket_type:
		Enums.TrinketType.CADDIE:
			return "Caddie"
		Enums.TrinketType.PLAYER:
			return "Player"
		Enums.TrinketType.SITUATIONAL:
			return "Situational"
	return "Unknown"


func is_caddie_trinket() -> bool:
	return trinket_type == Enums.TrinketType.CADDIE


func is_player_trinket() -> bool:
	return trinket_type == Enums.TrinketType.PLAYER


func is_situational_trinket() -> bool:
	return trinket_type == Enums.TrinketType.SITUATIONAL


func apply_to_player(player: GolferAttributes) -> void:
	"""Apply this trinket's effect to a player (for player-type trinkets)"""
	if trinket_type == Enums.TrinketType.PLAYER:
		player.apply_trinket_effect(effect_type, effect_value)


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"flavor_text": flavor_text,
		"rarity": rarity,
		"trinket_type": trinket_type,
		"effect_type": effect_type,
		"effect_value": effect_value
	}


static func from_dict(data: Dictionary) -> Trinket:
	var trinket := Trinket.new()
	trinket.id = data.get("id", "")
	trinket.name = data.get("name", "")
	trinket.description = data.get("description", "")
	trinket.flavor_text = data.get("flavor_text", "")
	trinket.rarity = data.get("rarity", Enums.TrinketRarity.COMMON)
	trinket.trinket_type = data.get("trinket_type", Enums.TrinketType.CADDIE)
	trinket.effect_type = data.get("effect_type", Enums.TrinketEffectType.WIND_SENSE)
	trinket.effect_value = data.get("effect_value", 1.0)
	return trinket
