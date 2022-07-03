extends Spatial

onready var board = $Board
var end_game_scene = preload("res://src/misc/GameOverSCreen.tscn");

export var sensitivity = 0.02;


var noise: OpenSimplexNoise;
var noise_counter = 0;
var noise_amount = 0.3;

func _ready() -> void:
	randomize();
	Events.connect("end_game", self, "_on_game_end");
	noise = OpenSimplexNoise.new();
	noise.seed = randi();
	noise.octaves = 4
	noise.period = 10.0
	noise.persistence = 0.8


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		else: 
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);


func _process(delta: float) -> void:
	noise_counter += 1;
	board.rotation_degrees.x += noise.get_noise_1d(noise_counter)*noise_amount;
	board.rotation_degrees.z += noise.get_noise_1d(noise_counter+50)*noise_amount;


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var move_xy = event.relative;

		board.rotate_x(-move_xy.y*0.01*sensitivity);
		board.rotate_z(move_xy.x*0.01*sensitivity);
		board.rotation_degrees.x = clamp(board.rotation_degrees.x, -10.0, 10.0);
		board.rotation_degrees.z = clamp(board.rotation_degrees.z, -10.0, 10.0);


func _on_game_end() -> void:
	var result_time = GameController.get_result_time();
	$Ball.queue_free();
	var end_game_scene_instance = end_game_scene.instance();
	add_child(end_game_scene_instance);
	end_game_scene_instance._set_result_label(str(result_time) + " s");
