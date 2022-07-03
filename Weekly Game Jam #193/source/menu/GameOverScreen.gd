extends Control

onready var winner1 = $MarginContainer/VBoxContainer/HBoxContainer/ButtonsContainer/NinePatchRect2/Winner1
onready var winner2 = $MarginContainer/VBoxContainer/HBoxContainer/ButtonsContainer/NinePatchRect2/Winner2
onready var winner_name = $MarginContainer/VBoxContainer/WinnerName

func _ready() -> void:
	register_buttons()
	
	if GameManager.winner_id == "player1":
		winner1.show()
		winner1.modulate = GameManager.global_settings[GameManager.winner_id + "_color"]
	if GameManager.winner_id == "player2":
		winner2.show()
		winner2.modulate = GameManager.global_settings[GameManager.winner_id + "_color"]
	
	winner_name.text = GameManager.global_settings[GameManager.winner_id + "_name"] + " wins"
	

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("ui_buttons")
	for button in buttons:
		button.connect("pressed", self, "_on_button_pressed", [button])


func _on_button_pressed(button) -> void:
	match button.name:
		"MainMenuButton":
			winner1.hide()
			winner2.hide()
			GameManager.reset_global_settings()
			get_tree().change_scene_to(GameManager.main_menu)
