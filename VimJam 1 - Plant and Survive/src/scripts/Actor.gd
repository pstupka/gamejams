extends KinematicBody2D
class_name Actor


const FLOOR_NORMAL: = Vector2.UP;

export var speed: = Vector2(50.0, 100.0)
export var gravity: = 300.0

var _velocity: = Vector2.ZERO
var _start_position = Vector2.ZERO

#knockback variables
export var knockback_impulse = 100.0
var knockback_direction: Vector2
var knockback = 0
const KNOCKBACK_COOLDOWN = 10

# Health section
export var max_health = 100
var current_health = max_health


# Dead or alive
enum STATES {ALIVE, DEAD}
var state = STATES.ALIVE

func handle_knockback(
		linear_velocity: Vector2,
		direction: Vector2,
		impulse: float
	) -> Vector2:
	var out: = linear_velocity
	if knockback > 0:
		knockback -= 1
	out = -direction * impulse
	out.y = out.y * 0.5
	return out

