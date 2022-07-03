extends StaticBody

var is_on = true
var discovered = false

func interact():
	is_on = !is_on
	$Particles.emitting = is_on
	$AudioStreamPlayer3D.stream_paused = !is_on
	
	if is_on:
		$DiscoverArea/DiscoverParticles.emitting = false
	else:
		$DiscoverArea/DiscoverParticles.emitting = true

func _on_DiscoverArea_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and !is_on:
		$DiscoverArea/DiscoverParticles.emitting = true


func _on_DiscoverArea_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		$DiscoverArea/DiscoverParticles.emitting = false
