extends KinematicBody2D

export var SPEED = 20;
export var GRAVITY = 10;
export var JUMP_SPEED = 300;

onready var animated_sprite = $AnimatedSprite;


var _velocity: Vector2;
var _direction: Vector2;


func _ready() -> void:
	pass;


func _physics_process(delta: float) -> void:
	_velocity.y += GRAVITY
	
	_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_velocity.y -= JUMP_SPEED
		

	
	_velocity.x = _direction.x * SPEED;
	_velocity = move_and_slide(_velocity, Vector2.UP);
	handle_animation_state()


func handle_animation_state():
	if _direction.x > 0:
		animated_sprite.flip_h = false;
	if _direction.x < 0:
		animated_sprite.flip_h = true;
		
	if _velocity.y < 0:
		animated_sprite.play("jump");
		return;
	if _velocity.y > 0:
		animated_sprite.play("fall");
		return;
		
	if _direction.x:
		animated_sprite.play("walk");
		return;
		
	if _direction.x == 0:
		animated_sprite.play("idle");
		return;
