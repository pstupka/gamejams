extends Node2D


export(PackedScene) var _bullet
onready var _audio_player = $AudioPlayer


const speed = 100
var mouse_position
var cooldown = 0


func _process(_delta) -> void:
	mouse_position = get_local_mouse_position()
	rotation += mouse_position.angle()
	
	if cooldown:
		cooldown -= 1

func _input(_event):
	if Input.is_action_just_pressed("shoot") and cooldown == 0:
		cooldown = 5;
		play_audio_from_resource("res://Assets/Audio/audio_shoot.wav")
		var bullet = _bullet.instance()
		bullet.set_shoot_direction(
			(get_global_mouse_position() - global_position).normalized())
		bullet.transform = global_transform
		get_tree().current_scene.add_child(bullet)

func play_audio_from_resource(name: String):
	var tmp_stream = load(name)
	_audio_player.set_stream(tmp_stream)
	_audio_player.play()

