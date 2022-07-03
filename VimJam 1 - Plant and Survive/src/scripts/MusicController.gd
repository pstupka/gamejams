extends Control

# Load the music player node
onready var _player = $AudioStreamPlayer

# Calling this function will load the given track, and play it
func play(track_url : String):
	var track = load(track_url)
	_player.stream = track
	_player.play()

# Calling this function will stop the music
func stop():
	_player.stop()

func _ready():
	_player.set_volume_db(-5)
	play("res://Assets/Audio/audio_music.wav")
