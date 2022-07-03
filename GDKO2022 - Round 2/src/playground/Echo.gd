extends Light2D

var target;

func _ready() -> void:
	randomize();
	rotation_degrees = rand_range(0.0, 360.0);
	scale = Vector2.ZERO;
	$AnimationPlayer.play("expand")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	call_deferred("queue_free")


func _on_EchoArea_body_entered(body: Node) -> void:
	if body.is_in_group("ToneStone"):
		body.play_tone();
		
