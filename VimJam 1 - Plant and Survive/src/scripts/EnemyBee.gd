extends Actor


onready var _animated_sprite = $AnimatedSprite
var target = null
var start_position: Vector2
var is_attacking: bool = false
const MIN_DISTANCE: float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemies")
	start_position = global_position
	_animated_sprite.play("idle")
	set_physics_process(false)


func _physics_process(delta):
	if target:
		_velocity = global_position.direction_to(target.global_position)
		if knockback:
			_velocity = handle_knockback(
				_velocity, 
				knockback_direction, 
				knockback_impulse)
			_velocity = _velocity*0.02
		position += _velocity * speed * delta
	else:
		if global_position.distance_to(start_position) > MIN_DISTANCE:
			_velocity = global_position.direction_to(start_position)
		else: 
			_velocity = Vector2.ZERO
			set_physics_process(false)
		position += _velocity * speed * 0.5 * delta

func _process(_delta: float) -> void:
	handle_animation_state(_velocity)


func handle_animation_state(velocity: Vector2) -> void:
	if velocity.x > 0:
		_animated_sprite.flip_h = false
	elif velocity.x < 0:
		_animated_sprite.flip_h = true
	_animated_sprite.animation = "attack" if is_attacking else "idle"


func _on_DiscoverArea_body_entered(body):
	if body.name == "Player":
		target = body
		is_attacking = true
		set_physics_process(true)


func _on_DiscoverArea_body_exited(body):
	if body.name == "Player":
		target = null
		is_attacking = false


func _on_Enemy_body_entered(body):
	if body.name == "Player":
		knockback = 10
		knockback_direction = global_position.direction_to(body.global_position)
	if body.is_in_group("bullets"):
		if current_health <= 0:
			queue_free()
		else:
			current_health -= 50
