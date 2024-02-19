extends Node

@onready var audio_players = get_children()

func _enter_tree():
	AudioServer.add_bus(1)
	AudioServer.add_bus(2)
	AudioServer.set_bus_name(1, "SFX")
	AudioServer.set_bus_name(2, "Music")

func play_sound(sound_name: String, volume_db: float = 0, extention: String = ".wav"):
	for audio_player in audio_players:
		if !audio_player.playing:
			audio_player.set_bus("SFX")
			audio_player.stream = load("res://Assets/Audio/Sfx/"+sound_name+extention)
			audio_player.volume_db = volume_db
			audio_player.play()
			break

func play_random_sound(sound_names: Array, volume_db: float = 0, extention: String = ".wav"):
	for audio_player in audio_players:
		if !audio_player.playing:
			audio_player.set_bus("SFX")
			audio_player.stream = load("res://Assets/Audio/Sfx/"+choose(sound_names)+extention)
			audio_player.volume_db = volume_db
			audio_player.play()
			break

func play_track(track_name: String, volume_db: float = 0, extention: String = ".wav"):
	for audio_player in audio_players:
		if audio_player.stream == load("res://Assets/Audio/Music/"+track_name+extention):
			return
		if !audio_player.playing:
			audio_player.set_bus("Music")
			audio_player.stream = load("res://Assets/Audio/Music/"+track_name+extention)
			audio_player.volume_db = volume_db
			audio_player.play()
			break

func stop_track():
	for audio_player in audio_players:
		if audio_player.get_bus() == "Music":
			audio_player.stop()

func stop_specific_track(track_name: String, extention: String = ".wav"):
	for audio_player in audio_players:
		if audio_player.stream == load("res://Assets/Audio/Music/"+track_name+extention):
			audio_player.stop()

func set_track_volume(volume: int):
	for audio_player in audio_players:
		if audio_player.get_bus() == "Music":
			audio_player.volume_db = volume

func is_track_playing(track_name: String, extention: String = ".wav"):
	for audio_player in audio_players:
		if audio_player.stream == load("res://Assets/Audio/Music/"+track_name+extention):
			return true
	return false

func replace_track(track_name: String, volume: int = 0, extention: String = ".wav"):
	for audio_player in audio_players:
		if audio_player.get_bus() == "Music":
			audio_player.stop()
		audio_player.set_bus("Music")
		audio_player.stream = load("res://Assets/Audio/Music/"+track_name+extention)
		audio_player.volume_db = volume
		audio_player.play()
		return

func choose(arr: Array):
	randomize()
	arr.shuffle()
	return arr.front()
