extends Control

onready var blur = $Blur;
var blur_amount = 0;


onready var result_label = $GameOverMenu/CenterContainer/VBoxContainer/Result


func _ready() -> void:
	pass;


func _process(delta: float) -> void:
	if blur_amount < 3.0:
		blur_amount = blur_amount + delta * 0.01;
		blur.material.set_shader_param("blur_amount", blur_amount);


func _on_RestartButton_pressed() -> void:
	Events.emit_signal("restart_game");


func _set_result_label(result) -> void:
	result_label.text = result;
