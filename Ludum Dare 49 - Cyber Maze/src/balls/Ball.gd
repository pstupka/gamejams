extends RigidBody

export (PackedScene) var spark;

func _process(delta: float) -> void:
	if global_transform.origin.y < -50.0:
		Events.emit_signal("end_game");

func _integrate_forces(state):
	if (state.get_contact_count() == 0): return;
	var collider = state.get_contact_collider_object(0);
	if collider.is_in_group("Rings"):
		$ZapPlayer.play();
		var position = state.get_contact_local_position(0);
		var spark_instance = spark.instance();
		get_tree().current_scene.add_child(spark_instance)
		spark_instance.transform.origin = position;
	else:
		$ZapPlayer.stop();

