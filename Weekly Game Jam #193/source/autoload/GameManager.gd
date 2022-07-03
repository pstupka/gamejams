extends Node


var gravity = 100

var main_level = preload("res://source/levels/TestLevel.tscn")
var game_over = preload("res://source/menu/GameOverScreen.tscn")
var main_menu = preload("res://source/menu/MainMenu.tscn")

var _player1 = preload("res://source/actors/Player.tscn")
var _player2 = preload("res://source/actors/Player2.tscn")


var game_end = false

var color_palette = [
	Color("e4a672"),
	Color("b86f50"),
	Color("743f39"),
#	Color("3f2832"),
	Color("9e2835"),
	Color("e53b44"),
	Color("fb922b"),
	Color("ffe762"),
	Color("63c64d"),
	Color("327345"),
	Color("193d3f"),
	Color("4f6781"),
	Color("afbfd2"),
	Color("ffffff"),
	Color("2ce8f4"),
	Color("0484d1")
]

var global_settings = {
	"player1_color": Color("e4a672"),
	"player1_name": "",
	
	"player2_color": Color("e4a672"),
	"player2_name": ""
}

var wind_direction = Vector2(0,0)
var wind_strength = 10000

var player1 : Player
var player2 : Player
var current_player

var winner_id = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.connect("new_game", self, "_on_new_game_started")
	Events.connect("turn_completed", self, "_on_turn_completed")
	Events.connect("player_died", self, "_on_player_died")


func _on_new_game_started() -> void:
	player1 = _player1.instance()
	player1.id = "player1"

	
	player2 = _player2.instance()
	player2.id = "player2"
	
	game_end = false
	winner_id = ""
	
	get_tree().change_scene_to(main_level)
	yield(get_tree().create_timer(0.1),"timeout")

	current_player = player1

	if global_settings["player1_name"] != "":
		player1.player_name = global_settings["player1_name"]
		
	if global_settings["player2_name"] != "":
		player2.player_name = global_settings["player2_name"]
	current_player.start_turn()


func _on_turn_completed() -> void:
	if !game_end:
		current_player.end_turn()

		if current_player == player1:
			current_player = player2
		else:
			current_player = player1

		current_player.start_turn()


func _on_player_died(player : Player) -> void:
	if winner_id == "":
		if player == player1:
			winner_id = player2.id
		else:
			winner_id = player1.id
		game_end = true
		yield(get_tree().create_timer(2),"timeout")
		
		
		player1.queue_free()
		player2.queue_free()
		current_player.queue_free()

		get_tree().change_scene_to(game_over)

func reset_global_settings() -> void:
	global_settings["player1_name"] = ""
	global_settings["player1_color"] = color_palette[0]

	global_settings["player2_name"] = ""
	global_settings["player2_color"] = color_palette[0]
	
