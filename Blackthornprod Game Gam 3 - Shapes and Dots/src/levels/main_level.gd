extends Node2D

onready var score_label = $scoreLabel
onready var multiplier_label = $multiplierLabel
onready var countdown_timer = $TimeControl/CountdownTimer
onready var countdown_label = $TimeControl/CountdownLabel
onready var play_board = $PlayBoard

var held_object = null


export var dots_amount = 50
export var block_position = Vector2(800, 200)
var spawn_margin = 40

var _dot = preload("res://src/blocks/dot.tscn")

var blocks = [preload("res://src/blocks/block1.tscn"),
	 preload("res://src/blocks/block2.tscn"),
	 preload("res://src/blocks/block3.tscn"),
	 preload("res://src/blocks/block4.tscn"),
	 preload("res://src/blocks/block5.tscn"),
	 preload("res://src/blocks/block6.tscn")]

func _ready():
	randomize()

func new_game():
	$GameOverLabel.hide()
	$MainMenu.hide()
	$Credits.hide()
	$Rules.hide()
	GameManager.time_left = 60
	GameManager.score = 0
	GameManager.points_multiplier = 1
	
	spawn_dots(dots_amount, play_board.position.x+spawn_margin, play_board.position.y+spawn_margin,
		play_board.get_node("border").texture.get_width()-2*spawn_margin,
		play_board.get_node("border").texture.get_height()-2*spawn_margin)
		
	add_block(block_position)
	countdown_timer.start()

func game_over():
	yield(get_tree().create_timer(0.5), "timeout")
	GameManager.play_audio_from_resource("res://assets/audio/drawing_sound_1.wav")
	for dot in get_tree().get_nodes_in_group("dots"):
		dot.queue_free()
	for block in get_tree().get_nodes_in_group("pickable"):
		block.queue_free()
	$GameOverLabel.show()
	$MainMenu.show()
	$Rules.hide()
	countdown_timer.stop()
	
	

func add_block(_position: Vector2):

	var block = blocks[GameManager.rng.randi_range(0,5)].instance()
	block.position = _position
	block.connect("clicked", self, "_on_pickable_clicked")
	block.connect("dots_consumed", self, "_on_dots_consumed")
	add_child(block)
	GameManager.play_audio_from_resource("res://assets/audio/drawing_sound_1.wav")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if held_object and !event.pressed:
			held_object.drop()
			# TODO 
			# Below should be repraced with some kind of animation and destroying items. <- depends on the desired gameplay
#			held_object.disconnect("clicked", self, "_on_pickable_clicked") #This prevents from moving object once again

			held_object = null

func _on_pickable_clicked(object):
	if !held_object:
		held_object = object
		held_object.pickup()

func _on_dots_consumed(greens: int, reds: int) -> void:
	
	GameManager.time_left = GameManager.time_left - 2*reds if GameManager.time_left - 2*reds >= 0 else 0  
	GameManager.points_multiplier = GameManager.points_multiplier if not reds else 1
	countdown_label.text = str("Time left: ", GameManager.time_left)
	
	GameManager.apply_score(greens*GameManager.points_multiplier)
	score_label.text = str("Score: ", GameManager.score)
	
	if greens and not reds:
		GameManager.points_multiplier += 1
		GameManager.time_left += 2
		countdown_label.text = str("Time left: ", GameManager.time_left)
	
	multiplier_label.text = str("Multiplier: x", GameManager.points_multiplier)
	add_block(block_position)

func _on_CountdownTimer_timeout():
	if GameManager.time_left <= 0:
		game_over()
		return
		
	GameManager.time_left -= 1
	countdown_label.text = str("Time left: ", GameManager.time_left)

func spawn_dots(amount, x, y, size_x, size_y):
	for i in amount:
		var dot = _dot.instance()
		dot.position = Vector2(
			GameManager.rng.randi_range(x, x+size_x),
			GameManager.rng.randi_range(y, y+size_y))
		if randf() < 0.2:
			dot.type = dot.RED
		else:
			dot.type = dot.GREEN
		add_child(dot)


func _on_StartButton_pressed() -> void:
	new_game()


func _on_CreditsButton_pressed() -> void:
	$Credits.show()
	$Rules.hide()
	$GameOverLabel.hide()
	GameManager.play_audio_from_resource("res://assets/audio/drawing_sound_1.wav")


func _on_RulesButton_pressed() -> void:
	$Credits.hide()
	$Rules.show()
	$GameOverLabel.hide()
	GameManager.play_audio_from_resource("res://assets/audio/drawing_sound_1.wav")
