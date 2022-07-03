extends Control

onready var player1_sprite = $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer/NinePatchRect/Player1
onready var player1_name = $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer/Player1Name
var player1_color = 0

onready var player2_sprite = $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer2/NinePatchRect2/Player2
onready var player2_name = $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer2/Player2Name
var player2_color = 0

func _ready() -> void:
	register_buttons()
	player1_sprite.modulate = GameManager.color_palette[0]
	player2_sprite.modulate = GameManager.color_palette[0]


func register_buttons():
	var buttons = get_tree().get_nodes_in_group("ui_buttons")
	for button in buttons:
		button.connect("pressed", self, "_on_button_pressed", [button])


func _on_button_pressed(button) -> void:
	match button.name:
		"StartButton":
			if player1_name.text == "":
				GameManager.global_settings["player1_name"] = "Player 1"
			else:
				GameManager.global_settings["player1_name"] = player1_name.text
				
			if player2_name.text == "":
				GameManager.global_settings["player2_name"] = "Player 2"
			else:
				GameManager.global_settings["player2_name"] = player2_name.text

			Events.emit_signal("new_game")
		"CreditsButton":
			print("CreditsButton pressed")
		"AboutButton":
			print("AboutButton pressed")
		"Player1Left":
			player1_color -= 1
			if player1_color < 0:
				player1_color = 0
			player1_sprite.modulate = GameManager.color_palette[player1_color]
			GameManager.global_settings["player1_color"] = GameManager.color_palette[player1_color]
		"Player1Right":
			player1_color += 1
			if player1_color > GameManager.color_palette.size()-1:
				player1_color = GameManager.color_palette.size()-1
			player1_sprite.modulate = GameManager.color_palette[player1_color]
			GameManager.global_settings["player1_color"] = GameManager.color_palette[player1_color]
		"Player2Left":
			player2_color -= 1
			if player2_color < 0:
				player2_color = 0
			player2_sprite.modulate = GameManager.color_palette[player2_color]
			GameManager.global_settings["player2_color"] = GameManager.color_palette[player2_color]
		"Player2Right":
			player2_color += 1
			if player2_color > GameManager.color_palette.size()-1:
				player2_color = GameManager.color_palette.size()-1
			player2_sprite.modulate = GameManager.color_palette[player2_color]
			GameManager.global_settings["player2_color"] = GameManager.color_palette[player2_color]

