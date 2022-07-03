extends Spatial

export var rotation_speed = 0.1;

func _ready() -> void:
	randomize();
	for i in range(2,5):
		get_node("Ring" + str(i)).rotate_y(rand_range(0, 360))
	$WinArea.connect("body_entered", self, "_on_winarea_body_entered");
	$AnimationPlayer.play("Countdown");

func _physics_process(delta: float) -> void:
	var vel = rotation_speed*delta;
	
	$Ring2.rotate_y(deg2rad(-vel));
	$Ring3.rotate_y(deg2rad(vel));
	$Ring4.rotate_y(deg2rad(-vel));
	$Ring5.rotate_y(deg2rad(vel));


func _on_winarea_body_entered(body):
	if body.is_in_group("Balls"):
		Events.emit_signal("end_game");	


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Countdown":
		Events.emit_signal("start_game");
