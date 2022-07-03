extends Node2D

var _player = preload("res://src/Actors/Player.tscn")
var _enemy = preload("res://src/Actors/EnemyBee.tscn")
var _item_crate = preload("res://src/Items/Crate.tscn")

var player
var crates_collected = 0
var plants01_collected = 0

var level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$HUD.hide()


func new_game():
	randomize()
	level = 1
	$HUD/LevelNumber.text = "Level %d" % [level]
	player = _player.instance()
	player._start_position = $StartPosition.position
	add_child(player)
	player.connect("died", self, "_on_Player_died")
	player.connect("health_changed", $HUD, "_on_Player_health_changed")
	$HUD.show()
	spawn_enemies()
	
	call_deferred("register_items")

# Function to spawn items inthe world
func register_items():
	var items = get_tree().get_nodes_in_group("items")
	for item in items:
		item.connect("picked", self, "_on_item_picked")

func spawn_enemies():
	for i in 10*level:
		var enemy = _enemy.instance()
		enemy.position.x = randi()%800
		enemy.position.y = randi()%240 - 160
		add_child(enemy)
		
	for i in 10*level:
		var enemy = _enemy.instance()
		enemy.position.x = randi()%870 + 830
		enemy.position.y = randi()%400 - 160
		add_child(enemy)

func _on_Player_died():
	$HUD.hide()
	$Scenes.game_over();

func _on_item_picked(item):
	match item.type:
		"crate":
			crates_collected += 1
			$HUD/CratesLabel.text = "x  %d" % [crates_collected]
		"plant01":
			plants01_collected += 1
			$HUD/Plant01Label.text = "x  %d" % [plants01_collected]


func _on_NextLevel_area_entered(area):
	if area.is_in_group("PlayerArea"):
		level += 1
		$HUD/LevelNumber.text = "Level %d" % [level]
#		spawn_enemies()
		var items = get_tree().get_nodes_in_group("items")
		for item in items:
			item.show()
