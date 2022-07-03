shader_type spatial;
render_mode unshaded,cull_front;


uniform float strength : hint_range(0,1) = 0.5;

void vertex(){
	vec4 camera_space_position = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	float dist = -camera_space_position.z;
	VERTEX += NORMAL * strength * dist / length(WORLD_MATRIX[0]);
}

void fragment (){
	ALBEDO = vec3(0);
}