## Handles all audio playback for the game
extends Node

# Audio buses
const MASTER_BUS := "Master"
const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const AMBIENT_BUS := "Ambient"

# Audio players
var _music_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []

# Settings
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 1.0
var ambient_volume: float = 0.8

# Currently playing
var current_music: String = ""
var current_ambient: String = ""

const MAX_SFX_PLAYERS := 8


func _ready() -> void:
	_setup_audio_players()
	_load_volume_settings()


func _setup_audio_players() -> void:
	# Music player
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = MUSIC_BUS
	add_child(_music_player)

	# Ambient player
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = AMBIENT_BUS
	add_child(_ambient_player)

	# SFX player pool
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		_sfx_players.append(player)


func _load_volume_settings() -> void:
	var settings := SaveManager.load_settings()
	master_volume = settings.get("master_volume", 1.0)
	music_volume = settings.get("music_volume", 0.7)
	sfx_volume = settings.get("sfx_volume", 1.0)
	_apply_volumes()


func _apply_volumes() -> void:
	# Set bus volumes
	var master_idx := AudioServer.get_bus_index(MASTER_BUS)
	var music_idx := AudioServer.get_bus_index(MUSIC_BUS)
	var sfx_idx := AudioServer.get_bus_index(SFX_BUS)
	var ambient_idx := AudioServer.get_bus_index(AMBIENT_BUS)

	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(master_volume))
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(music_volume))
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(sfx_volume))
	if ambient_idx >= 0:
		AudioServer.set_bus_volume_db(ambient_idx, linear_to_db(ambient_volume))


func set_master_volume(volume: float) -> void:
	master_volume = clampf(volume, 0.0, 1.0)
	_apply_volumes()


func set_music_volume(volume: float) -> void:
	music_volume = clampf(volume, 0.0, 1.0)
	_apply_volumes()


func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	_apply_volumes()


func play_music(music_path: String, fade_duration: float = 1.0) -> void:
	if music_path == current_music and _music_player.playing:
		return

	current_music = music_path

	if _music_player.playing and fade_duration > 0:
		# Fade out current music
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(_start_new_music.bind(music_path, fade_duration))
	else:
		_start_new_music(music_path, fade_duration)


func _start_new_music(music_path: String, fade_duration: float) -> void:
	var stream := load(music_path) as AudioStream
	if stream:
		_music_player.stream = stream
		_music_player.volume_db = -80.0 if fade_duration > 0 else 0.0
		_music_player.play()

		if fade_duration > 0:
			var tween := create_tween()
			tween.tween_property(_music_player, "volume_db", 0.0, fade_duration)


func stop_music(fade_duration: float = 1.0) -> void:
	if not _music_player.playing:
		return

	current_music = ""

	if fade_duration > 0:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(_music_player.stop)
	else:
		_music_player.stop()


func play_ambient(ambient_path: String, fade_duration: float = 2.0) -> void:
	if ambient_path == current_ambient and _ambient_player.playing:
		return

	current_ambient = ambient_path

	if _ambient_player.playing and fade_duration > 0:
		var tween := create_tween()
		tween.tween_property(_ambient_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(_start_new_ambient.bind(ambient_path, fade_duration))
	else:
		_start_new_ambient(ambient_path, fade_duration)


func _start_new_ambient(ambient_path: String, fade_duration: float) -> void:
	var stream := load(ambient_path) as AudioStream
	if stream:
		_ambient_player.stream = stream
		_ambient_player.volume_db = -80.0 if fade_duration > 0 else 0.0
		_ambient_player.play()

		if fade_duration > 0:
			var tween := create_tween()
			tween.tween_property(_ambient_player, "volume_db", 0.0, fade_duration)


func stop_ambient(fade_duration: float = 2.0) -> void:
	if not _ambient_player.playing:
		return

	current_ambient = ""

	if fade_duration > 0:
		var tween := create_tween()
		tween.tween_property(_ambient_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(_ambient_player.stop)
	else:
		_ambient_player.stop()


func play_sfx(sfx_path: String, volume_db: float = 0.0, pitch_variance: float = 0.0) -> void:
	var stream := load(sfx_path) as AudioStream
	if not stream:
		push_warning("Could not load SFX: %s" % sfx_path)
		return

	# Find available player
	var player: AudioStreamPlayer = null
	for p in _sfx_players:
		if not p.playing:
			player = p
			break

	if not player:
		# All players busy, use the first one (oldest)
		player = _sfx_players[0]

	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	player.play()


func play_sfx_at_position(sfx_path: String, position: Vector3, volume_db: float = 0.0) -> void:
	# For 3D positional audio, would need AudioStreamPlayer3D
	# For now, just play as 2D
	play_sfx(sfx_path, volume_db)


# Common SFX shortcuts
func play_shot_sound(shot_type: Enums.ShotType) -> void:
	match shot_type:
		Enums.ShotType.DRIVE:
			play_sfx("res://assets/audio/sfx/driver_hit.wav", 0.0, 0.05)
		Enums.ShotType.APPROACH:
			play_sfx("res://assets/audio/sfx/iron_hit.wav", -3.0, 0.05)
		Enums.ShotType.SHORT_GAME:
			play_sfx("res://assets/audio/sfx/chip.wav", -6.0, 0.05)
		Enums.ShotType.PUTT:
			play_sfx("res://assets/audio/sfx/putt.wav", -6.0, 0.03)
		Enums.ShotType.BUNKER:
			play_sfx("res://assets/audio/sfx/bunker.wav", -3.0, 0.05)


func play_ball_land_sound(lie: Enums.LieType) -> void:
	match lie:
		Enums.LieType.GREEN:
			play_sfx("res://assets/audio/sfx/ball_green.wav", -6.0, 0.1)
		Enums.LieType.FAIRWAY:
			play_sfx("res://assets/audio/sfx/ball_fairway.wav", -6.0, 0.1)
		Enums.LieType.WATER:
			play_sfx("res://assets/audio/sfx/splash.wav", 0.0, 0.05)
		Enums.LieType.GREENSIDE_BUNKER, Enums.LieType.FAIRWAY_BUNKER:
			play_sfx("res://assets/audio/sfx/ball_bunker.wav", -3.0, 0.1)
		_:
			play_sfx("res://assets/audio/sfx/ball_rough.wav", -6.0, 0.1)


func play_putt_hole_sound() -> void:
	play_sfx("res://assets/audio/sfx/ball_in_hole.wav", 0.0, 0.0)


func play_ui_sound(sound_name: String) -> void:
	var path := "res://assets/audio/sfx/ui_%s.wav" % sound_name
	play_sfx(path, -6.0, 0.0)


func play_crowd_reaction(is_positive: bool, intensity: float = 1.0) -> void:
	var path: String
	if is_positive:
		path = "res://assets/audio/sfx/crowd_cheer.wav"
	else:
		path = "res://assets/audio/sfx/crowd_groan.wav"
	play_sfx(path, -6.0 + (intensity * 6.0), 0.1)
