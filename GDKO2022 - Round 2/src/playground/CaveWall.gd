extends Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var polygon = points;
	
	var light_occluder = LightOccluder2D.new();
	light_occluder.occluder = OccluderPolygon2D.new();
	light_occluder.occluder.polygon = polygon;
	add_child(light_occluder);
	

	var collider = CollisionPolygon2D.new();
	var offset_polygon = Geometry.offset_polygon_2d(polygon, 7); # 7 jest git
	collider.polygon = offset_polygon[0];
	
	var static_body = StaticBody2D.new()
	static_body.add_child(collider);
	add_child(static_body);
	static_body.set_collision_layer_bit(2, true);
	

