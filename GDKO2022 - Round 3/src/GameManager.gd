extends Node

var has_keys = false
var player = null

func game_over():
	if player:
		player.can_move = false
