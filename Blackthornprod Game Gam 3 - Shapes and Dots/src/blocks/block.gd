extends Area2D

signal clicked
signal dots_consumed


onready var tween = $Tween
onready var sprite = $Sprite

var held = false
var initial_position: Vector2

export var dots_to_spawn = 5


func _ready() -> void:
	rove_in()
	initial_position = position

func _input_event(_viewport: Object, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)

func _physics_process(_delta):
	if held:
		global_transform.origin = get_global_mouse_position()

func pickup():
	if held:
		return
	held = true

func drop():
	var greens = 0
	var reds = 0
	
	var can_process: bool = true
	
	if held:
		var overlapping_areas = get_overlapping_areas()
		for area in overlapping_areas:
			if not area.is_in_group("dots"):
				can_process = false
				
		if not overlapping_areas.empty() and can_process:
			for area in overlapping_areas:
				# There is a bug if in the list another shape is inside the list not on the first place
				if (area.is_in_group("dots")):
					if area.type == area.GREEN:
						greens += 1
					if area.type == area.RED:
						reds += 1
					area.call_deferred("queue_free")
				else:
					tween_to_initial_position()
			if greens + reds > 0:
				rove_out()
				emit_signal("dots_consumed", greens, reds)
#			em1

		else: 
			tween_to_initial_position()
	held = false

func rove_in():
	tween.interpolate_property(sprite, 'scale',
		Vector2.ZERO, Vector2(1.0, 1.0), 1.2,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()

func rove_out():
	tween.interpolate_property(sprite, 'scale',
		Vector2(1.0, 1.0), Vector2.ZERO,  0.5,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(0.5), "timeout")
	
	
	get_parent().spawn_dots(dots_to_spawn, position.x, position.y,
		sprite.texture.get_width() - 40, sprite.texture.get_height() - 40)
	queue_free()

func tween_to_initial_position():
	tween.interpolate_property(self, 'position',
		position, initial_position, 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
