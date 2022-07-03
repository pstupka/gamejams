extends Node2D


onready var explosion_polygon = $ExplosionPolygon


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in explosion_polygon.polygon.size():
		explosion_polygon.polygon[i] += global_position
	
	$Particles.emitting = true
	$AudioStreamPlayer.play()
	yield(get_tree().create_timer(0.7),"timeout")
	queue_free()

