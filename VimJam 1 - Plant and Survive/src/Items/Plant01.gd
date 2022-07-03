extends Node2D


signal picked

var can_be_picked = false
var type = "plant01"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("items")


func _on_item_area_entered(area):
	if area.is_in_group("pick"):
		can_be_picked = true

func _on_item_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("pick") and can_be_picked:
		can_be_picked = false
		emit_signal("picked", self)
		hide()

func _on_item_area_exited(area):
	if area.is_in_group("pick"):
		can_be_picked = false
