#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;

layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	vec2 _pad;
} params;

void main() {
	ivec2 texel = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);

	if (texel.x >= size.x || texel.y >= size.y) {
		return;
	}

	vec4 fcolor = imageLoad(color_image, texel);
	imageStore(color_image, texel, fcolor);
}
