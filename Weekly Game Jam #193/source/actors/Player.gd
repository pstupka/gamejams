extends KinematicBody2D
class_name Player


# Movement section
export var SPEED = 80
export var GRAVITY = 500
export var JUMP_SPEED = 230
var velocity = Vector2()
var direction = 0.0
var can_move = false

export (float, 0, 1.0) var FRICTION = 0.9
export (float, 0, 1.0) var ACCELERATION = 0.25

var MAX_SLOPE_ANGLE = 60

# Camera section
var camera_initial_zoom
onready var camera2d = $Camera2D
onready var tweenCameraZoom = $Camera2D/TweenCameraZoom

# Animation Player
onready var animation_player = $AnimationPlayer

onready var weapon = $Weapon
onready var tween = $Tween

export var MAX_HEALTH = 200.0
var current_health = MAX_HEALTH

# Player settings
var player_color : Color
var player_name : String setget set_name

var id : String

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Players")
	player_color = GameManager.global_settings[id + "_color"]
	$Pivot/Sprite.modulate = player_color
	
	camera_initial_zoom = camera2d.zoom
	
	$HealthBar.max_value = MAX_HEALTH
	$HealthBar.value = MAX_HEALTH
	current_health = MAX_HEALTH
	
	animation_player.play("player_animation_idle")
	weapon.hide()


func _process(delta: float) -> void:
	pass
#	if camera2d.current:
#		var direction_to_mouse = get_global_mouse_position() - global_position
#		var distance_to_mouse = global_position.distance_to(get_global_mouse_position())
#		if distance_to_mouse > 20:
#			# Arbitrary values applied
#			camera2d.offset_h = lerp(camera2d.offset_h, direction_to_mouse.normalized().x*2, 0.5)
#			camera2d.offset_v = lerp(camera2d.offset_v, direction_to_mouse.normalized().y*2, 0.5)


func _physics_process(delta):
	if can_move:
		process_input(delta)
	process_movement(delta)
	handle_animation_state()
	if position.y > 1000:
		Events.emit_signal("player_died", self)


func _unhandled_key_input(event):
	if event.is_action_pressed("camera_zoom_out"):
		tweenCameraZoom.interpolate_property($Camera2D,
			"zoom",
			camera_initial_zoom,
			2 * camera_initial_zoom,
			0.6,
			Tween.TRANS_EXPO,
			Tween.EASE_OUT
		)
		tweenCameraZoom.start()
	if event.is_action_released("camera_zoom_out"):
		tweenCameraZoom.interpolate_property($Camera2D,
			"zoom",
			$Camera2D.zoom,
			camera_initial_zoom,
			0.6,
			Tween.TRANS_EXPO,
			Tween.EASE_OUT
		)
		tweenCameraZoom.start()


func process_input(_delta):
	direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			$FootstepPlayer.stop()
			$JumpPlayer.play()
			velocity.y -= JUMP_SPEED
			
	if Input.is_action_just_pressed("fire"):
		$Weapon.load_weapon()
#		$Weapon.fire_bullet()
	if Input.is_action_just_released("fire"):
		$Weapon.interrupt_loading()


func process_movement(delta):
	velocity.y += GRAVITY * delta

	if direction != 0:
		velocity.x = lerp(velocity.x, direction * SPEED, ACCELERATION)
	else:
		velocity.x = 0
	
	velocity = move_and_slide(velocity, Vector2.UP, true, 4, deg2rad(MAX_SLOPE_ANGLE))


func handle_animation_state() -> void:
	if direction != 0:
		animation_player.play("player_animation_run")
	if !is_on_floor():
		animation_player.play("player_animation_still")

	if velocity.y > 0 and direction == 0:
		$Pivot.rotation_degrees = 0
		animation_player.stop()
		animation_player.play("player_animation_still")
		return
	if direction == 0:
		$Pivot.rotation_degrees = 0
		animation_player.play("player_animation_idle")


func end_turn() -> void:
	can_move = false
	weapon.can_fire = false
	weapon.set_process(false)
	weapon.hide()
	direction = 0
	animation_player.play("player_animation_idle")
	camera2d.current = false


func start_turn() -> void:
	can_move = true
	weapon.can_fire = true
	weapon.set_process(true)
	weapon.show()
	
	camera2d.current = true


func take_damage(damage : float) -> void:
	var start_tween = current_health
	current_health -= damage
	if current_health <= 0:
		current_health = 0

		Events.emit_signal("player_died", self)
	$Tween.interpolate_property($HealthBar, "value", start_tween, current_health, 0.6, Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.start()
	
	if current_health < MAX_HEALTH * 0.6:
		$HealthBar.modulate = Color("fb922b")
	if current_health < MAX_HEALTH * 0.3:
		$HealthBar.modulate = Color("9e2835")


func set_name(name : String) -> void:
	player_name = name
	$NameLabel.text = name


func _on_Hitbox_area_entered(area):
	if area.is_in_group("Bullets"):
		var distance_to_center = global_position.distance_to(area.global_position)
		take_damage(clamp(10*area.get_parent().damage_factor/distance_to_center,0,50))
