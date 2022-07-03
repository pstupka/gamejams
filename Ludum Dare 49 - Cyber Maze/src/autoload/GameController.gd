extends Node

var start_time = 0.0;

var player = AudioStreamPlayer.new();


func _ready() -> void:
	Events.connect("end_game", self, "_on_game_end");
	Events.connect("restart_game", self, "_on_game_restart");
	Events.connect("start_game", self, "_on_game_start");
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	
	player.stream = load("res://assets/audio/435147__kickhat__ambient-drone-21-07-2018.wav");
	add_child(player);
	player.play();
	

func get_result_time() -> float:
	return (OS.get_ticks_msec() - start_time) * 0.001;


func _on_game_start() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	get_tree().current_scene.get_node("Ball").mode = RigidBody.MODE_RIGID;
	start_time = OS.get_ticks_msec();
	

func _on_game_end() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);


func _on_game_restart() -> void:
	get_tree().reload_current_scene();
	
