extends KinematicBody

onready var footstep_timer = $Spatial/FootstepTimer
onready var footstep_sound = $Spatial/FootstepSoundWood

enum State {IDLE, RUN, JUMP, FALL}

const JUMP_SPEED = 7
const JUMP_FRAMES = 1
const HOP_FRAMES = 3

export var mouse_y_sens = .1
export var mouse_x_sens = .1
export var move_speed = 10
export var acceleration = .5
export var gravity = -10
export var friction = 1.15
export var max_climb_angle = .6
export var angle_of_freedom = 80
export var boost_accumulation_speed = 1
export var max_boost_multiplier = 2

var can_move = true

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	randomize()
	GameManager.player = self


func _physics_process(delta):
	_process_input(delta)
	_process_movement(delta)
	_update_hud()

# Handles mouse movement
func _input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(event.relative.x * mouse_y_sens * -1))
		$UpperCollider/Camera.rotate_x(deg2rad(event.relative.y * mouse_x_sens * -1))
		
		var camera_rot = $UpperCollider/Camera.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, 90 + angle_of_freedom * -1, 90 + angle_of_freedom)
		$UpperCollider/Camera.rotation_degrees = camera_rot


var inbetween = false
func _on_tween_all_completed():
	inbetween = false
	crouch_floor = false


var state = State.FALL
var on_floor = false
var frames = 0
var crouching = false
var crouch_floor = false #true if started crouching on the floor
var input_dir = Vector3(0, 0, 0)
func _process_input(delta):
	if !can_move: return
	# Toggle mouse capture
	if Input.is_action_just_pressed("capture"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# WASD
	input_dir = Vector3(Input.get_action_strength("right") - Input.get_action_strength("left"), 
			0,
			Input.get_action_strength("back") - Input.get_action_strength("forward")).normalized()
			
	if input_dir:
		if footstep_timer.paused:
			footstep_timer.paused = false
	else:
		footstep_timer.paused = true
	
	
	if Input.is_action_just_pressed("interact"):
		var object_to_interact = $UpperCollider/Camera/RayCast.get_collider()
		if object_to_interact:
			if object_to_interact.has_method("interact"):
				object_to_interact.interact()


var collision : KinematicCollision  # Stores the collision from move_and_collide
var velocity := Vector3(0, 0, 0)
var rotation_buf = rotation  # used to calculate rotation delta for air strafing
var turn_boost = 1
func _process_movement(delta):
	# state management
	if !collision:
		on_floor = false
		if state != State.JUMP:
			state = State.FALL
	else:
		if state == State.JUMP:
			pass
		elif Vector3.UP.dot(collision.normal) < max_climb_angle:
			state = State.FALL
		else:
			on_floor = true
			if input_dir.length() > .1 && (frames > JUMP_FRAMES+HOP_FRAMES || frames == 0):
				state = State.RUN
				turn_boost = 1
			else:
				state = State.IDLE
	
	#jump state
	if state == State.JUMP && frames < JUMP_FRAMES:
		velocity.y = JUMP_SPEED
		frames += 1 * delta * 60
	elif state == State.JUMP:
		state = State.FALL

	#fall state
	if state == State.FALL:
		if inbetween && crouching && crouch_floor:
			velocity.y = gravity;
		if velocity.y > gravity:
			velocity.y += gravity * delta * 4
	
	#run state
	if state == State.RUN:
		velocity += input_dir.rotated(Vector3(0, 1, 0), rotation.y) * acceleration
		if Vector2(velocity.x, velocity.z).length() > (move_speed/2 if crouching else move_speed):
			velocity = velocity.normalized() * (move_speed/2 if crouching else move_speed)
		velocity.y = ((Vector3(velocity.x, 0, velocity.z).dot(collision.normal)) * -1)
		
		# fake gravity to keep character on the ground
		# increase if player is falling down slopes instead of running
		velocity.y -= .0001 + (int(velocity.y < 0) * 1.1)  
		

	#idle state
	if state == State.IDLE && frames < HOP_FRAMES + JUMP_FRAMES:
		frames += 1 * delta * 60
	elif state == State.IDLE:
		turn_boost = 1
		if velocity.length() > .5:
			velocity /= friction
			velocity.y = ((Vector3(velocity.x, 0, velocity.z).dot(collision.normal)) * -1) - .0001

	#air strafe
	if state > 2:
		#x axis movement
		var rotation_d = rotation - rotation_buf
		if input_dir.x > .1 && rotation_d.y < 0:
			velocity = velocity.rotated(Vector3.UP, rotation_d.y )
			turn_boost += boost_accumulation_speed * delta 
		elif input_dir.x < -.1 && rotation_d.y > 0:
			velocity = velocity.rotated(Vector3.UP, rotation_d.y ) 
			turn_boost += boost_accumulation_speed * delta 
		
		if abs(input_dir.x) < .1 && on_floor:
			#z axis movement
			var movement_vector = Vector3(0,0,input_dir.z).rotated(Vector3(0, 1, 0), rotation.y) * move_speed /2
			if movement_vector.length() < .1:
				velocity = velocity
			elif Vector2(velocity.x, velocity.z).length() < move_speed:
				var xy = Vector2(movement_vector.x , movement_vector.z).normalized()
				velocity += Vector3(xy.x, 0, xy.y) * acceleration
				
		turn_boost = clamp(turn_boost, 1, max_boost_multiplier)
		rotation_buf = rotation

	#apply
	if velocity.length() >= .5 || inbetween:
		collision = move_and_collide(velocity * Vector3(turn_boost, 1, turn_boost) * delta)
	else:
		velocity = Vector3(0, velocity.y, 0)
	if collision:
		if Vector3.UP.dot(collision.normal) < .5:
			velocity.y += delta * gravity
			clamp(velocity.y, gravity, 9999)
			velocity = velocity.slide(collision.normal).normalized() * velocity.length()
		elif turn_boost > 1.01:
			velocity = Vector3(velocity.x, velocity.y + ((Vector3(velocity.x, 0, velocity.z).dot(collision.normal)) * - 2) , velocity.z)
		else:
			velocity = velocity

func _update_hud():
	$HUD/Crosshair.modulate = Color.white
	var cursor_object = $UpperCollider/Camera/RayCast.get_collider()
	if cursor_object:		
		if cursor_object.is_in_group("Interactable"):
			$HUD/Crosshair.modulate = Color.green
		if cursor_object.is_in_group("Wall"):
			$HUD/Crosshair.modulate = Color.red

func _on_FootstepTimer_timeout() -> void:
	footstep_sound.pitch_scale = rand_range(0.9, 1.1)
	footstep_sound.play()


func _on_FloorDiscoverArea_body_entered(body: Node) -> void:
	if body.is_in_group("Rug"):
		footstep_sound = $Spatial/FootstepSoundCarpet


func _on_FloorDiscoverArea_body_exited(body: Node) -> void:
	if body.is_in_group("Rug"):
		footstep_sound = $Spatial/FootstepSoundWood
