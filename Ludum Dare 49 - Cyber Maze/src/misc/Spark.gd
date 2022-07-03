extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Particles.emitting = true;
	yield(get_tree().create_timer(0.3),"timeout");
	queue_free();

