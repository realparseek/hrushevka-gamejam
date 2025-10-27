shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 viewport_size = vec2(640, 480);
uniform vec2 virtual_resolution = vec2(640, 480);
uniform float shadow_smoothness = 0.5;
uniform int color_depth = 32;
uniform float dither_strength = 0.02;

// CRT эффекты
uniform float vignette_strength = 0.1;
uniform float chroma_aberration = 0.0005;

// Рябь как от ТВ шума
uniform float tv_noise_strength = 0.02;
uniform float tv_noise_speed = 3.0;

const float ps1_dither[16] = float [16](
	-4.0, 0.0, -3.0, 1.0,
	2.0, -2.0, 3.0, -1.0,
	-3.0, 1.0, -4.0, 0.0,
	3.0, -1.0, 2.0, -2.0
);

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec3 apply_tv_noise(vec3 color, vec2 uv) {
    if (tv_noise_strength <= 0.001) {
        return color;
    }

    float noise = random(uv * 100.0 + TIME * tv_noise_speed) * 2.0 - 1.0;
    vec3 noisy_color = color + noise * tv_noise_strength;
    return mix(color, noisy_color, 0.5);
}

vec3 apply_pixel_flicker(vec3 color, vec2 uv) {
    if (tv_noise_strength <= 0.001) {
        return color;
    }

    float pixel_flicker = random(floor(uv * viewport_size) + TIME * tv_noise_speed * 5.0);

    if (pixel_flicker > 0.95) {
        float flicker_amount = random(uv + TIME) * tv_noise_strength * 0.5;
        return color * (1.0 - flicker_amount);
    }

    return color;
}

vec3 smooth_quantize(vec3 color, int levels) {
    float step = 1.0 / float(levels - 1);
    vec3 quantized = floor(color / step + 0.5) * step;

    float blend = shadow_smoothness * (1.0 - length(color - quantized) * 2.0);
    blend = clamp(blend, 0.0, shadow_smoothness);

    return mix(color, quantized, blend);
}

bool is_shadow_color(vec3 color) {
    float brightness = dot(color, vec3(0.299, 0.587, 0.114));
    return brightness < 0.3;
}

vec3 apply_vignette(vec3 color, vec2 uv) {
    vec2 centered = uv - 0.5;
    float vignette = 1.0 - dot(centered, centered) * vignette_strength;
    return color * vignette;
}

vec3 apply_chroma_aberration(vec3 original_color, vec2 uv) {
    if (chroma_aberration <= 0.0001) {
        return original_color;
    }

    vec2 offset = vec2(chroma_aberration, 0.1);
    vec3 color = original_color;

    color.r = mix(color.r, texture(screen_texture, uv + offset).r, chroma_aberration * 10.0);
    color.b = mix(color.b, texture(screen_texture, uv - offset).b, chroma_aberration * 10.0);

    return color;
}

void fragment() {
    vec3 screen_color = texture(screen_texture, UV).rgb;

    vec2 virtual_pos = floor(FRAGCOORD.xy * (virtual_resolution / viewport_size));
    int x = int(mod(virtual_pos.x, 4.0));
    int y = int(mod(virtual_pos.y, 4.0));
    int index = y * 4 + x;

    float dither_offset = (ps1_dither[index] / 32.0);
    vec3 quantized_color = floor((screen_color * 255.0) / 8.0) / 31.0;

    if (is_shadow_color(screen_color)) {
        vec3 smooth_shadow = smooth_quantize(screen_color, color_depth);
        quantized_color = mix(quantized_color, smooth_shadow, shadow_smoothness);

        if (dot(screen_color, vec3(0.299, 0.587, 0.114)) < 0.2) {
            quantized_color += dither_offset * dither_strength;
        }
    }

    vec3 final_color = quantized_color;

    // Анти-алиасинг
    vec3 color_up = texture(screen_texture, UV + vec2(0.0, 1.0/viewport_size.y)).rgb;
    vec3 color_down = texture(screen_texture, UV + vec2(0.0, -1.0/viewport_size.y)).rgb;
    vec3 color_left = texture(screen_texture, UV + vec2(-1.0/viewport_size.x, 0.0)).rgb;
    vec3 color_right = texture(screen_texture, UV + vec2(1.0/viewport_size.x, 0.0)).rgb;

    vec3 average = (color_up + color_down + color_left + color_right) / 4.0;
    float similarity = 1.0 - distance(screen_color, average);

    if (similarity < 0.95) {
        final_color = mix(final_color, average, 0.1);
    }

    // Эффекты
    final_color = apply_tv_noise(final_color, UV);
    final_color = apply_pixel_flicker(final_color, UV);
    final_color = apply_chroma_aberration(final_color, UV);
    final_color = apply_vignette(final_color, UV);

    COLOR = vec4(final_color, 1.0);
}