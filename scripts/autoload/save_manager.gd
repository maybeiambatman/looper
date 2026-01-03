## Handles saving and loading game data
extends Node

const SAVE_PATH := "user://save_data.json"
const META_PATH := "user://meta_progress.json"
const SETTINGS_PATH := "user://settings.json"


func save_run(run_data: RunData, player: GolferAttributes, tournament: TournamentState) -> void:
	var save_dict := {
		"run_number": run_data.run_number,
		"difficulty": run_data.difficulty,
		"current_hole": run_data.current_hole,
		"hole_scores": run_data.hole_scores,
		"shots_taken": run_data.shots_taken,
		"good_decisions": run_data.good_decisions,
		"bad_decisions": run_data.bad_decisions,
		"player": player.to_dict(),
		"tournament": tournament.to_dict(),
		"trinkets": _trinkets_to_array(run_data.active_trinkets),
		"timestamp": Time.get_unix_time_from_system()
	}

	var json_string := JSON.stringify(save_dict, "\t")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Run saved successfully")
	else:
		push_error("Failed to save run: %s" % FileAccess.get_open_error())


func load_run() -> Dictionary:
	"""Returns a dictionary with run_data, player, and tournament, or empty dict if no save"""
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open save file")
		return {}

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse save file: %s" % json.get_error_message())
		return {}

	var save_dict: Dictionary = json.data
	var result := {}

	# Reconstruct run data
	var run_data := RunData.from_dict(save_dict)
	result["run_data"] = run_data

	# Reconstruct player
	if save_dict.has("player"):
		result["player"] = GolferAttributes.from_dict(save_dict.player)

	# Reconstruct tournament
	if save_dict.has("tournament"):
		result["tournament"] = TournamentState.from_dict(save_dict.tournament)

	# Reconstruct trinkets
	if save_dict.has("trinkets"):
		result["trinkets"] = _array_to_trinkets(save_dict.trinkets)

	return result


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_run_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Run save deleted")


func save_meta_progress(meta: MetaProgression) -> void:
	var meta_dict := meta.to_dict()
	var json_string := JSON.stringify(meta_dict, "\t")
	var file := FileAccess.open(META_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Meta progress saved")
	else:
		push_error("Failed to save meta progress: %s" % FileAccess.get_open_error())


func load_meta_progress() -> MetaProgression:
	if not FileAccess.file_exists(META_PATH):
		return MetaProgression.new()  # Fresh start

	var file := FileAccess.open(META_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open meta progress file")
		return MetaProgression.new()

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse meta progress file: %s" % json.get_error_message())
		return MetaProgression.new()

	return MetaProgression.from_dict(json.data)


func save_settings(settings: Dictionary) -> void:
	var json_string := JSON.stringify(settings, "\t")
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
	else:
		push_error("Failed to save settings")


func load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return _get_default_settings()

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return _get_default_settings()

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_string) != OK:
		return _get_default_settings()

	return json.data


func _get_default_settings() -> Dictionary:
	return {
		"master_volume": 1.0,
		"music_volume": 0.7,
		"sfx_volume": 1.0,
		"mouse_sensitivity": 0.002,
		"invert_y": false
	}


func _trinkets_to_array(trinkets: Array) -> Array:
	var arr := []
	for trinket in trinkets:
		if trinket and trinket is Trinket:
			arr.append(trinket.id)
	return arr


func _array_to_trinkets(arr: Array) -> Array:
	var trinkets := []
	for trinket_id in arr:
		if TrinketManager:
			var trinket = TrinketManager.get_trinket(trinket_id)
			if trinket:
				trinkets.append(trinket)
	return trinkets
