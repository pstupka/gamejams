extends StaticBody

var is_on = false

func interact():
	is_on = !is_on
	$Particles.emitting = is_on
	if !$AudioStreamPlayer3D.playing:
		$AudioStreamPlayer3D.play()
	else:
		$AudioStreamPlayer3D.stream_paused = !is_on
	
	if is_on:
		$DiscoverArea/DiscoverParticles.emitting = false
		$Close.play()
	else:
		$DiscoverArea/DiscoverParticles.emitting = true
		$Open.play()

func _on_DiscoverArea_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and !is_on:
		$DiscoverArea/DiscoverParticles.emitting = true


func _on_DiscoverArea_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		$DiscoverArea/DiscoverParticles.emitting = false
