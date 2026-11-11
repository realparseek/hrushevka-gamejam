shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture;

uniform bool enable_vignette = true;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.45;
uniform float vignette_softness : hint_range(0.01, 1.0) = 0.45;

uniform bool enable_grain = true;
uniform float grain_amount : hint_range(0.0, 0.3) = 0.006;
uniform float grain_scale : hint_range(1.0, 6.0) = 2.5;

uniform bool enable_chromatic = true;
uniform float chromatic_amount : hint_range(0.0, 0.05) = 0.0016;

uniform bool enable_distortion = true;
uniform float distortion_amount : hint_range(-0.6, 0.6) = -0.10;

uniform bool enable_flicker = true;
uniform float flicker_amount : hint_range(0.0, 0.4) = 0.02;

uniform bool enable_scanlines = false;
uniform float scanline_amount : hint_range(0.0, 0.5) = 0.05;

uniform float uv_wobble : hint_range(0.0, 0.05) = 0.0;

float bc_hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	uv += vec2(sin(TIME * 2.1), cos(TIME * 1.7)) * uv_wobble;

	// Бочкообразная дисторсия линзы.
	if (enable_distortion) {
		vec2 c = uv - 0.5;
		float r2 = dot(c, c);
		uv = 0.5 + c * (1.0 + distortion_amount * r2);
	}

	vec3 col;
	// Радиальная хроматическая аберрация.
	if (enable_chromatic) {
		vec2 dir = uv - 0.5;
		float d = length(dir);
		vec2 off = dir * chromatic_amount * (0.35 + d);
		col.r = texture(screen_texture, uv - off).r;
		col.g = texture(screen_texture, uv).g;
		col.b = texture(screen_texture, uv + off).b;
	} else {
		col = texture(screen_texture, uv).rgb;
	}

	// Зерно плёнки.
	if (enable_grain) {
		vec2 cell = floor(SCREEN_UV / max(SCREEN_PIXEL_SIZE * grain_scale, vec2(0.0000001)));
		float g = bc_hash(cell + vec2(TIME * 71.0, TIME * 37.0));
		col += (g - 0.5) * grain_amount;
	}

	// Мерцание экспозиции.
	if (enable_flicker) {
		float f = bc_hash(vec2(floor(TIME * 18.0), 3.7));
		col *= 1.0 - flicker_amount * f;
	}

	if (enable_scanlines) {
		float sl = sin(SCREEN_UV.y * 1440.0);
		col *= 1.0 - scanline_amount * (0.5 + 0.5 * sl);
	}

	// Виньетка.
	if (enable_vignette) {
		float dist = length(SCREEN_UV - 0.5) * 1.41421356;
		float vig = smoothstep(vignette_softness, 1.0, dist);
		col *= mix(1.0, 1.0 - vignette_strength, vig);
	}

	COLOR = vec4(col, 1.0);
}
