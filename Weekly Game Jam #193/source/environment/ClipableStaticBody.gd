extends StaticBody2D
class_name ClipableStaticBody

var polygon : Polygon2D setget set_polygon
var collision_polygon : CollisionPolygon2D
var outline : Line2D 

func _init(_polygon : Polygon2D):
	self.polygon = _polygon
	add_to_group("Clipable")
	add_to_group("Terrain")

func _ready():
	add_child(polygon)
	call_deferred("add_child", collision_polygon)
	add_child(outline)


func set_polygon(new_polygon : Polygon2D):
	if new_polygon == null:
		return
	polygon = new_polygon
	if collision_polygon == null:
		collision_polygon = CollisionPolygon2D.new()
	collision_polygon.set_polygon(polygon.polygon)
	if outline == null:
		outline = Line2D.new()
		outline.width = 3
		outline.default_color = Color("3f2832")
		outline.joint_mode = Line2D.LINE_JOINT_ROUND
		outline.set_points(polygon.polygon)
		outline.add_point(outline.points[0])

		
# Some bug when clippimg polygon approaches from the left
func clip_static_body(polygon_to_clip : PoolVector2Array) -> Array:
	var clipped_array = Geometry.clip_polygons_2d(polygon.polygon, polygon_to_clip)
	
	# polygon_to_clip covers whole base polygon
	if clipped_array.size() == 0:
		call_deferred("queue_free")
		return []
	
	if clipped_array.size() > 0:
		if clipped_array.size() > 1:
			if Geometry.is_polygon_clockwise(clipped_array[1]):
				return[]
		polygon.set_polygon(clipped_array[0])
		collision_polygon.call_deferred("set_polygon", clipped_array[0]) 
		outline.set_points(clipped_array[0])
		outline.add_point(outline.points[0])

	clipped_array.remove(0)
	return clipped_array


func set_color(color : Color):
	polygon.color = color


func set_texture(texture : Texture):
	polygon.texture = texture
