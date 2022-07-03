extends KinematicBody2D

onready var echo_preset = preload("res://src/playground/Echo.tscn");
onready var footstep_echo_preset = preload("res://src/playground/FootstepSoundWave.tscn");

export var SPEED: float = 20.0;
export var GRAVITY: float = 10.0;
export var JUMP_SPEED: float = 300.0;
export var SPRITE_MODULATION_PEAK: float = 20.0;
export var SPRITE_MODULATION_FADE_SPEED: float = 10.0;
export var INERTIA = 100;

const FLOOR_NORMAL = Vector2.UP;
const SNAP_DIRECTION = Vector2.DOWN;
const SNAP_LENGTH = 64.0;
const SLOPE_THRESHOLD = deg2rad(80);

onready var animated_sprite = $AnimatedSprite;
onready var cooldown_sound_wave_timer = $CooldownSoundWave;

var _velocity: Vector2;
var _direction: Vector2;
var _sprite_modulation: float = 1.0;
var _just_landed = false;

var _snap_vector = SNAP_DIRECTION * SNAP_LENGTH;

enum STATE {IDLE, JUMP, WALK, FALL};
var player_state = STATE.IDLE;

var item_queue = [];
var item_hold : RigidBody2D = null;

func _ready() -> void:
	Global.player = self;
	

func _process(delta: float) -> void:
	_sprite_modulation = lerp(_sprite_modulation, 15.0, SPRITE_MODULATION_FADE_SPEED * delta);
	animated_sprite.modulate = Color(1, _sprite_modulation, _sprite_modulation, 1);
	
	if player_state == STATE.WALK and animated_sprite.frame == 1:
		generate_footstep();
	
	if is_on_floor():
		if _just_landed:
			generate_footstep();
			_snap_vector = SNAP_DIRECTION * SNAP_LENGTH;
			_just_landed = false
	else:
		if !_just_landed:
			_just_landed = true
	
	if item_hold:
		item_hold.global_position = lerp(item_hold.global_position, $HoldPosition.global_position, 0.07);

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if item_hold:
			item_hold.mode = RigidBody2D.MODE_CHARACTER;
			item_hold = null;
		elif item_queue.size():
			item_hold = item_queue[0];
			item_hold.mode = RigidBody2D.MODE_STATIC;
			
	
	if Input.is_action_just_pressed("soundwave"):
		if cooldown_sound_wave_timer.is_stopped():
			var echo = echo_preset.instance();
			add_child(echo)
			echo.set_as_toplevel(true);
			echo.global_position = global_position;
			cooldown_sound_wave_timer.start();
			_sprite_modulation = SPRITE_MODULATION_PEAK;
	
	_velocity.y += GRAVITY
	
	_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_snap_vector = Vector2.ZERO;
		_velocity.y -= JUMP_SPEED;
		player_state = STATE.JUMP;
		animated_sprite.play("jump");
		generate_footstep();
		
	_velocity.x = _direction.x * SPEED;
	_velocity = move_and_slide(_velocity, Vector2.UP,true, 4, PI/4, false);
#	_velocity.y = move_and_slide_with_snap(_velocity, _snap_vector,
#			FLOOR_NORMAL, true, 4, SLOPE_THRESHOLD, false).y;
	handle_player_state()
	
	for index in get_slide_count():
		var collision = get_slide_collision(index);
		if collision.collider.is_in_group("ToneStone"):
			collision.collider.apply_central_impulse(-collision.normal * INERTIA);


func handle_player_state():
	if _direction.x > 0:
		animated_sprite.flip_h = false;
	if _direction.x < 0:
		animated_sprite.flip_h = true;
		
	if _velocity.y > 0 and not is_on_floor():
		player_state = STATE.FALL;
		animated_sprite.play("jump");
		
	if _direction.x and is_on_floor():
		player_state = STATE.WALK;
		animated_sprite.play("walk");
		return;
		
	if _direction.x == 0 and is_on_floor():
		player_state = STATE.IDLE;
		animated_sprite.play("idle");
		return;


func generate_footstep() -> void:
	var footstep_echo = footstep_echo_preset.instance();
	add_child(footstep_echo)
	footstep_echo.set_as_toplevel(true);
	footstep_echo.global_position = global_position + Vector2(_direction.x * 8, 0);


func _on_DiscoverArea_body_entered(body: Node) -> void:
	if body.is_in_group("ToneStone"):
		item_queue.append(body);
		body.timer_pause(true);
		body.glow(1, true);


func _on_DiscoverArea_body_exited(body: Node) -> void:
	if not body.is_in_group("ToneStone"): 
		return;
	if item_queue.has(body):
		body.timer_pause(false);
		body.glow(1, false);
		item_queue.remove(item_queue.find(body));
