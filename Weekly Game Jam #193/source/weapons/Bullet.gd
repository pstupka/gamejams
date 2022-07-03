extends RigidBody2D

export(PackedScene) var explosion
onready var timer = $Timer

var damage = 30
var damage_factor = 70

func _ready() -> void:
	add_force(Vector2.ZERO, GameManager.wind_direction * GameManager.wind_strength)


func _process(delta: float) -> void:
	$CollisionShape2D.rotation = linear_velocity.angle()
	$bullet.rotation = linear_velocity.angle()
	
	if position.y > 1000:
		Events.emit_signal("turn_completed")
		queue_free()


func _on_body_entered(body: Node) -> void:
	sleeping = true
	$CollisionShape2D.call_deferred("set_disabled", true)
	hide()
	var explosion_instance = explosion.instance()
	explosion_instance.global_position = global_position
	get_tree().current_scene.add_child(explosion_instance)
	Events.emit_signal("bullet_exploded", explosion_instance.explosion_polygon)
	$Hitbox/HitboxCollision.call_deferred("set_disabled", false)
	timer.start()


func _on_Timer_timeout() -> void:
	Events.emit_signal("turn_completed")
	queue_free()
