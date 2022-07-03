extends Node2D


var explosion : PackedScene = preload("res://source/environment/Explosion.tscn")
var ground_texture = Texture

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var init_poly = Polygon2D.new()
	init_poly.set_polygon($initPolygon.polygon)
	ground_texture = $initPolygon.texture
	$initPolygon.queue_free()
	var clipable_body = ClipableStaticBody.new(init_poly)
	
	
	clipable_body.set_texture(ground_texture)
	add_child(clipable_body)
	
	GameManager.player1.position = $Player1Position.position
	GameManager.player2.position = $Player2Position.position
	add_child(GameManager.player1)
	add_child(GameManager.player2)
	
	
	Events.connect("bullet_exploded", self, "_on_bullet_exploded")


func _on_bullet_exploded(explosion : Polygon2D):

	for clippable in get_tree().get_nodes_in_group("Clipable"):
		var leftovers : Array = clippable.clip_static_body(explosion.polygon)
		for area in leftovers:
			var poly = Polygon2D.new()
			poly.set_polygon(area)
			var body = ClipableStaticBody.new(poly)

			body.set_texture(ground_texture)
			add_child(body)
