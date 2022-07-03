extends Light2D

func _ready() -> void:
	randomize();
	rotation_degrees = rand_range(0.0, 360.0);
	$AnimationPlayer.play("expand")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	call_deferred("queue_free")
