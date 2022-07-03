extends CanvasLayer


onready var _health_bar = $HealthBar


# Called when the node enters the scene tree for the first time.
func _ready():
	var player_max_health = 100
	_health_bar.max_value = player_max_health

func _on_Player_health_changed(value):
	_health_bar.value = value
	
func hide():
	for node in get_children():
		node.hide()

func show():
	for node in get_children():
		node.show()
