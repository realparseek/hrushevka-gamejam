shader_type canvas_item;

uniform vec2 custom_viewport_size = vec2(720.0, 480.0);
uniform vec2 virtual_resolution = vec2(720.0, 480.0);
uniform float shadow_smoothness = 0.6;
uniform int color_depth = 64;
uniform float dither_strength = 0.01;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

const float ps1_dither[16] = float[16](
    -4.0,  0.0, -3.0,  1.0,
     2.0, -2.0,  3.0, -1.0,
    -3.0,  1.0, -4.0,  0.0,
     3.0, -1.0,  2.0, -2.0
);

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

void fragment() {
    vec3 screen_color = texture(screen_texture, UV).rgb;

    vec2 virtual_pos = floor(FRAGCOORD.xy * (virtual_resolution / custom_viewport_size));
    int x = int(mod(virtual_pos.x, 4.0));
    int y = int(mod(virtual_pos.y, 4.0));
    int index = y * 4 + x;
    float dither_offset = ps1_dither[index] / 32.0;

    vec3 quantized_color = floor((screen_color * 255.0) / 8.0) / 31.0;

    if (is_shadow_color(screen_color)) {
        vec3 smooth_shadow = smooth_quantize(screen_color, color_depth);
        quantized_color = mix(quantized_color, smooth_shadow, shadow_smoothness);

        float brightness = dot(screen_color, vec3(0.299, 0.587, 0.114));
        if (brightness < 0.01) {
            quantized_color += dither_offset * dither_strength;
        }
    }

    vec3 final_color = quantized_color;

    vec2 pixel_step = SCREEN_PIXEL_SIZE;
    vec3 color_up    = texture(screen_texture, UV + vec2(0.0,  pixel_step.y)).rgb;
    vec3 color_down  = texture(screen_texture, UV + vec2(0.0, -pixel_step.y)).rgb;
    vec3 color_left  = texture(screen_texture, UV + vec2(-pixel_step.x, 0.0)).rgb;
    vec3 color_right = texture(screen_texture, UV + vec2( pixel_step.x, 0.0)).rgb;

    vec3 average = (color_up + color_down + color_left + color_right) / 4.0;
    float similarity = 1.0 - distance(screen_color, average);

    if (similarity < 0.95) {
        final_color = mix(final_color, average, 0.1);
    }

    COLOR = vec4(final_color, 1.0);
}