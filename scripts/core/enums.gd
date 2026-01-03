## Core enumerations used throughout Final Five
class_name Enums
extends RefCounted

enum ShotType {
	DRIVE,
	APPROACH,
	SHORT_GAME,
	PUTT,
	BUNKER,
	RECOVERY
}

enum ShotShape {
	STRAIGHT,
	FADE,
	DRAW,
	PUNCH,
	HIGH,
	FLOP,
	BUMP_AND_RUN,
	SPINNER
}

enum LieType {
	TEE,
	FAIRWAY,
	LIGHT_ROUGH,
	HEAVY_ROUGH,
	FAIRWAY_BUNKER,
	GREENSIDE_BUNKER,
	HARDPAN,
	DIVOT,
	BURIED,
	PINE_STRAW,
	FRINGE,
	GREEN,
	WATER
}

enum ShotResult {
	PERFECT,
	GOOD,
	ACCEPTABLE,
	POOR,
	DISASTER
}

enum PressureLevel {
	COMFORTABLE,
	CLOSE,
	MUST_PERFORM,
	WIN_OR_LOSE
}

enum HoleType {
	PAR_3_SHORT,
	PAR_3_LONG,
	PAR_4_RISK_REWARD,
	PAR_4_POSITIONAL,
	PAR_5_REACHABLE
}

enum CourseTheme {
	AUGUSTA,      # Flowering, fast greens, dramatic elevation
	PEBBLE,       # Coastal, windy, cliffside
	ST_ANDREWS,   # Links, pot bunkers, running game
	OAKMONT       # Punishing rough, church pew bunkers
}

enum TrinketRarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY
}

enum TrinketType {
	CADDIE,
	PLAYER,
	SITUATIONAL
}

enum TrinketEffectType {
	# Caddie effects
	WIND_SENSE,
	YARDAGE_HINT,
	GREEN_READ_HINT,
	TEMPERATURE_HINT,
	PRESSURE_REDUCTION,
	BOOK_PRECISION,
	CONFIDENCE_INDICATOR,
	LIE_DETAIL,

	# Player stat boosts
	POWER_BOOST,
	ACCURACY_BOOST,
	SHORT_GAME_BOOST,
	PUTTING_BOOST,
	CLUTCH_BOOST,
	CONSISTENCY_BOOST,
	RECOVERY_BOOST,
	IRON_PLAY_BOOST,

	# Situational
	MULLIGAN,
	LEADER_PRESSURE,
	CROWD_BOOST,
	FAVORABLE_CONDITIONS,
	OUTCOME_PREVIEW
}

# Helper functions for enums
static func get_shot_type_name(type: ShotType) -> String:
	match type:
		ShotType.DRIVE: return "Drive"
		ShotType.APPROACH: return "Approach"
		ShotType.SHORT_GAME: return "Short Game"
		ShotType.PUTT: return "Putt"
		ShotType.BUNKER: return "Bunker"
		ShotType.RECOVERY: return "Recovery"
	return "Unknown"

static func get_shot_shape_name(shape: ShotShape) -> String:
	match shape:
		ShotShape.STRAIGHT: return "Straight"
		ShotShape.FADE: return "Fade"
		ShotShape.DRAW: return "Draw"
		ShotShape.PUNCH: return "Punch"
		ShotShape.HIGH: return "High"
		ShotShape.FLOP: return "Flop"
		ShotShape.BUMP_AND_RUN: return "Bump and Run"
		ShotShape.SPINNER: return "Spinner"
	return "Unknown"

static func get_lie_type_name(lie: LieType) -> String:
	match lie:
		LieType.TEE: return "Tee"
		LieType.FAIRWAY: return "Fairway"
		LieType.LIGHT_ROUGH: return "Light Rough"
		LieType.HEAVY_ROUGH: return "Heavy Rough"
		LieType.FAIRWAY_BUNKER: return "Fairway Bunker"
		LieType.GREENSIDE_BUNKER: return "Greenside Bunker"
		LieType.HARDPAN: return "Hardpan"
		LieType.DIVOT: return "Divot"
		LieType.BURIED: return "Buried Lie"
		LieType.PINE_STRAW: return "Pine Straw"
		LieType.FRINGE: return "Fringe"
		LieType.GREEN: return "Green"
		LieType.WATER: return "Water"
	return "Unknown"

static func get_result_name(result: ShotResult) -> String:
	match result:
		ShotResult.PERFECT: return "Perfect"
		ShotResult.GOOD: return "Good"
		ShotResult.ACCEPTABLE: return "Acceptable"
		ShotResult.POOR: return "Poor"
		ShotResult.DISASTER: return "Disaster"
	return "Unknown"

static func get_result_color(result: ShotResult) -> Color:
	match result:
		ShotResult.PERFECT: return Color.GOLD
		ShotResult.GOOD: return Color.GREEN
		ShotResult.ACCEPTABLE: return Color.WHITE
		ShotResult.POOR: return Color.ORANGE
		ShotResult.DISASTER: return Color.RED
	return Color.WHITE

static func get_pressure_name(pressure: PressureLevel) -> String:
	match pressure:
		PressureLevel.COMFORTABLE: return "Comfortable"
		PressureLevel.CLOSE: return "Close"
		PressureLevel.MUST_PERFORM: return "Must Perform"
		PressureLevel.WIN_OR_LOSE: return "Win or Lose"
	return "Unknown"

static func get_rarity_color(rarity: TrinketRarity) -> Color:
	match rarity:
		TrinketRarity.COMMON: return Color.GRAY
		TrinketRarity.UNCOMMON: return Color.GREEN
		TrinketRarity.RARE: return Color.BLUE
		TrinketRarity.LEGENDARY: return Color.GOLD
	return Color.WHITE
