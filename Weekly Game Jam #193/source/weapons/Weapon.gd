extends Node2D

onready var crosshair = $Crosshair
onready var animation_player = $AnimationPlayer
onready var progress = $Crosshair/TextureProgress
var bullet = preload("res://source/weapons/Bullet.tscn")

export var impulse : float = 1000
var can_fire = false

func _ready():
	set_process(false)


func _process(delta):
	var mouse_position = get_global_mouse_position()
	crosshair.look_at(mouse_position)
	if (crosshair.global_position.x - mouse_position.x < 0):
		crosshair.scale.y = 1
	else:
		crosshair.scale.y = -1


func fire_bullet():
	$FirePlayer.play()
	$LoadingPlayer.stop()
	get_parent().camera2d.current = false
	var bullet_instance : RigidBody2D = bullet.instance()
	var direction = global_position.direction_to(get_global_mouse_position()).normalized()
	bullet_instance.position = $Crosshair/Sprite.global_position
	bullet_instance.apply_central_impulse(direction * impulse * progress.value)
	get_parent().get_parent().add_child(bullet_instance)
	can_fire = false
	progress.hide()
	progress.value = 0


func load_weapon():
	if can_fire:
		progress.show()
		animation_player.play("loading")


func interrupt_loading():
	if animation_player.is_playing():
		animation_player.stop()
		fire_bullet()


func _on_loading_finished(anim_name):
	fire_bullet()
