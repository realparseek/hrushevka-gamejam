#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;

// uniform vec2 custom_viewport_size = vec2(640.0, 360.0);
// uniform vec2 virtual_resolution = vec2(640.0, 360.0);
// uniform float shadow_smoothness = 0.6;
// uniform float dither_strength = 0.01;
// uniform float color_depth = 64;

layout(push_constant, std430) uniform Params {
	vec2 custom_viewport_size;
	vec2 virtual_resolution;
	float shadow_smoothness;
	float dither_strength;
	float color_depth;
	float _pad;
} params;

const float ps1_dither[16] = float[16](
    -4.0,  0.0, -3.0,  1.0,
     2.0, -2.0,  3.0, -1.0,
    -3.0,  1.0, -4.0,  0.0,
     3.0, -1.0,  2.0, -2.0
);

vec3 smooth_quantize(vec3 color, int levels) {
    float step = 1.0 / float(levels - 1);
    vec3 quantized = floor(color / step + 0.5) * step;
    float blend = params.shadow_smoothness * (1.0 - length(color - quantized) * 2.0);
    blend = clamp(blend, 0.0, params.shadow_smoothness);
    return mix(color, quantized, blend);
}

bool is_shadow_color(vec3 color) {
    float brightness = dot(color, vec3(0.299, 0.587, 0.114));
    return brightness < 0.3;
}

void main() {
    ivec2 texel = ivec2(gl_GlobalInvocationID.xy);
    ivec2 img_size = imageSize(color_image);

		if (texel.x >= img_size.x || texel.y >= img_size.y) {
        return;
    }

		vec2 uv = (vec2(texel) + 0.5) / vec2(img_size);

		vec2 virtual_uv = floor(uv * params.virtual_resolution)
		                / params.virtual_resolution;

		ivec2 source_texel = ivec2(
		    virtual_uv * vec2(img_size)
		);

		source_texel = clamp(source_texel, ivec2(0), img_size - 1);

		vec4 fcolor = imageLoad(color_image, source_texel);
		float screen_brightness = 1.1;
		vec3 screen_color = fcolor.rgb*screen_brightness;

    // vec4 fcolor = imageLoad(color_image, texel);
		// float screen_brightness = 1.3;
    // vec3 screen_color = fcolor.rgb * screen_brightness;

    vec2 virtual_pos = floor(vec2(texel) * (params.virtual_resolution / params.custom_viewport_size));
    int x = int(mod(virtual_pos.x, 4.0));
    int y = int(mod(virtual_pos.y, 4.0));
    int index = y * 4 + x;
    float dither_offset = ps1_dither[index] / 32.0;

    vec3 quantized_color = floor((screen_color * 255.0) / 8.0) / 31.0;

    if (is_shadow_color(screen_color)) {
        vec3 smooth_shadow = smooth_quantize(screen_color*screen_brightness, int(params.color_depth));
        quantized_color = mix(quantized_color, smooth_shadow, params.shadow_smoothness);

        float brightness = dot(screen_color, vec3(0.299, 0.587, 0.114));
        if (brightness < 0.2) {
            quantized_color += dither_offset * params.dither_strength;
        }
    }

    vec3 final_color = quantized_color;

    ivec2 texel_up    = min(texel + ivec2(0, 1), img_size - 1);
    ivec2 texel_down  = max(texel + ivec2(0, -1), ivec2(0));
    ivec2 texel_left  = max(texel + ivec2(-1, 0), ivec2(0));
    ivec2 texel_right = min(texel + ivec2(1, 0), img_size - 1);

    vec3 color_up    = imageLoad(color_image, texel_up).rgb;
    vec3 color_down  = imageLoad(color_image, texel_down).rgb;
    vec3 color_left  = imageLoad(color_image, texel_left).rgb;
    vec3 color_right = imageLoad(color_image, texel_right).rgb;

    vec3 average = (color_up + color_down + color_left + color_right) / 4.0;
    float similarity = 1.0 - distance(screen_color, average);

    if (similarity < 0.95) {
        final_color = mix(final_color, average, 0.1);
    }

    imageStore(color_image, texel, vec4(final_color, 1.0));
}