extends KinematicBody2D


const VELOCITY = 200
var _direction: Vector2 


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("bullets")


func _physics_process(delta):
	position += _direction * VELOCITY * delta


func set_shoot_direction(direction: Vector2):
	_direction = direction


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Bullet_body_entered(body):
	if body.is_in_group("enemies"):
		queue_free()
