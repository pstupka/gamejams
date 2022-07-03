extends StaticBody

func interact():
	$AudioStreamPlayer.play()
	GameManager.has_keys = true;
	$CollisionShape.disabled = true

func _on_DiscoverArea_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		$DiscoverArea/DiscoverParticles.emitting = true


func _on_DiscoverArea_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		$DiscoverArea/DiscoverParticles.emitting = false


func _on_AudioStreamPlayer_finished() -> void:
	call_deferred("queue_free")
