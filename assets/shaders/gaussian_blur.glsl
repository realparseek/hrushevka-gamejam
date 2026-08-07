#[compute]
#version 450 core

layout (local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
layout (rgba16f, set = 0, binding = 0) uniform image2D color_image;
layout (set = 0, binding = 1) uniform sampler2D depth_image;

void main() {
  ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
  float depth = texelFetch(depth_image, uv, 0).r;
  imageStore(color_image, uv, vec4(depth, depth, depth, 1.0));
}