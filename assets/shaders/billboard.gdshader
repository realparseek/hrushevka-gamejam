shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo_tex;

void vertex() {
	vec3 dir = CAMERA_POSITION_WORLD - NODE_POSITION_WORLD;
	dir.y = 0.;
	dir = normalize(dir);
	mat3 bt = mat3(cross(vec3(0.,1.,0.), dir), vec3(0.,1.,0.), dir);
	VERTEX = bt * VERTEX;
	NORMAL = dir;
}

void fragment() {
	vec4 col = texture(albedo_tex, UV);
	ALBEDO = col.rgb * 0.001;
	ALPHA = col.a;
}