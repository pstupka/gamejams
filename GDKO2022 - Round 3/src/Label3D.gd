extends Spatial


export var label_text = "Label"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Viewport/Label.text = label_text

