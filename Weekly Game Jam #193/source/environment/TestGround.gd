extends StaticBody2D

onready var _polygon = $Polygon
onready var _collision_polygon = $CollisionPolygon

# Called when the node enters the scene tree for the first time.
func _ready():
	_collision_polygon.set_polygon(_polygon.polygon)
	add_to_group("Clipable")


func clip_static_body(polygon_to_clip : PoolVector2Array) -> void:
	var clipped_array = Geometry.clip_polygons_2d(_polygon.polygon, polygon_to_clip)
	if clipped_array.size() > 1: 
		# JAk mamy size >1 wbija przypadek, kiedy polygon_to_clip znajduje sie wewnątrze
		var body = StaticBody2D.new()
		
		var collision = CollisionPolygon2D.new()
		collision.set_polygon(clipped_array[1])
		
		var polygon_detached = Polygon2D.new()
		polygon_detached.set_polygon(clipped_array[1])
		polygon_detached.color = Color.red
		
		body.add_child(collision)
		body.add_child(polygon_detached)
		get_parent().add_child(body)
		
	_polygon.set_polygon(clipped_array[0])
	_collision_polygon.set_polygon(clipped_array[0])
