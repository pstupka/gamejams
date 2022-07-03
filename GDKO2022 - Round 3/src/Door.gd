extends StaticBody

func interact():
	if GameManager.has_keys:
		$Open.play()
		GameManager.game_over()
		$Label3D.show()
		$DiscoverArea/DiscoverParticles.emitting = false
	else:
		$Knob.play()
	

func _on_DiscoverArea_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		$DiscoverArea/DiscoverParticles.emitting = true


func _on_DiscoverArea_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		$DiscoverArea/DiscoverParticles.emitting = false
