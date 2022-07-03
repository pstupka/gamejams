extends Area2D

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
enum {RED, GREEN}
var type = GREEN
var offset = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == GREEN:
		offset = GameManager.rng.randi_range(0,2)*16
	else:
		offset = GameManager.rng.randi_range(3,5)*16
	$Sprite.region_rect = Rect2(offset,0,16,16)
	GameManager.play_audio_from_resource("res://assets/audio/drawing_sound_2.wav")

func set_modulation(color: Color) -> void:
	$Sprite.modulate = color

func get_modulation() -> Color:
	return $Sprite.modulate
