extends Node2D


var score = 0
var time_left = 60
var points_multiplier = 1

var rng = RandomNumberGenerator.new()
var audio_player 
var music_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	audio_player = AudioStreamPlayer.new()
	music_player = AudioStreamPlayer.new()
	add_child(audio_player)
	add_child(music_player)
	
	var tmp_stream = load("res://assets/audio/music.wav")
	music_player.stream = tmp_stream
	
	music_player.play()
	

func apply_score(consumed_greens: int):
	score += consumed_greens

func play_audio_from_resource(name: String):
	var tmp_stream = load(name)
	audio_player.stream = tmp_stream
	audio_player.play()
	
	var music_bus_id = AudioServer.get_bus_count()
	AudioServer.add_bus()
	AudioServer.set_bus_name(music_bus_id,"music")
	# connects music to master bus
	AudioServer.set_bus_send(music_bus_id,"Master")
	audio_player.bus = "music"
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
