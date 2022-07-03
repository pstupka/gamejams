shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_toon,specular_toon, world_vertex_coords;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_emission : hint_black_albedo;
uniform vec4 emission : hint_color;
uniform float emission_energy;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform vec4 down_color : hint_color ;
uniform vec4 up_color : hint_color = vec4(0.243, 0.537, 0.282, 1.0);

varying flat vec4 out_color;

uniform float threshold : hint_range(-10.0, 10.0) = -10;

vec3 lerpColor(vec4 a, vec4 b, float t){
	float rr =  a.r + (b.r - a.r) * t;
	float gg =  a.g + (b.g - a.g) * t;
	float bb =  a.b + (b.b - a.b) * t;
	return vec3(rr, gg, bb);
}

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;

	out_color = vec4(down_color.r, down_color.g, down_color.b, 0.0);
	
	if (VERTEX.y > threshold){
		out_color = mix(down_color, up_color, clamp((VERTEX.y - threshold) * 10.0, 0.0, 1.0));
	}
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = out_color.rgb * albedo_tex.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	vec3 emission_tex = texture(texture_emission,base_uv).rgb;
	EMISSION = (emission.rgb+emission_tex)*emission_energy;
}
