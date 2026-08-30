shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture: hint_screen_texture;
uniform float color_level: hint_range(0.0, 1000.0, 1.0);
uniform float noise_level: hint_range(0.0, 1.0, 0.00001);

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	
	float grayscale = max(color.r, max(color.g, color.b));
	float lower = floor(grayscale*color_level) / color_level;
	float higher = ceil(grayscale*color_level) / color_level;
	float lowerdiff = abs(lower-grayscale);
	float higherdiff = abs(higher-grayscale);
	float level = lowerdiff < higherdiff ? lower : higher;
	float adjust = level / grayscale;
	color.rgb *= adjust;
	
	float noise = random(UV + vec2(TIME));
    vec4 static_color = vec4(vec3(noise), 1.0);
    color = mix(color, static_color, noise_level);
	
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
