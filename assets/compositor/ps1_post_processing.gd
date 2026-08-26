@tool
extends CompositorEffect
class_name PS1PostProcessing

var rd: RenderingDevice
var shader: RID
var pipeline: RID

func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	enabled = true
	rd = RenderingServer.get_rendering_device()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if shader.is_valid():
			rd.free_rid(shader)

func _ensure_shader() -> bool:
	if pipeline.is_valid():
		return true
	if not rd:
		return false

	var shader_file := load("res://assets/shaders/ps1_post_processing.glsl") as RDShaderFile
	if not shader_file:
		return false

	var spirv := shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(spirv)
	if not shader.is_valid():
		return false

	pipeline = rd.compute_pipeline_create(shader)
	return pipeline.is_valid()


func _render_callback(_effect_type: int, render_data: RenderData) -> void:
	if not rd or not _ensure_shader():
		return

	var render_scene_buffers = render_data.get_render_scene_buffers() as RenderSceneBuffersRD
	if not render_scene_buffers: return

	var size = render_scene_buffers.get_internal_size()
	if size.x == 0 or size.y == 0: return
	
	var x_groups = ceili(float(size.x) / 8.0)
	var y_groups = ceili(float(size.y) / 8.0)

	# uniform vec2 custom_viewport_size = vec2(640.0, 360.0);
	# uniform vec2 virtual_resolution = vec2(640.0, 360.0);
	# uniform float shadow_smoothness = 0.6;
	# uniform float dither_strength = 0.01;
	# uniform float color_depth = 64;
	# uniform float _padding;

	var constants = PackedFloat32Array([640.0*3.0, 480.0*3.0, 640.0, 480.0, 0.6, 0.005, 64.0, 0.0])

	var view_count = render_scene_buffers.get_view_count()
	for view in range(view_count):
		var color_image: RID = render_scene_buffers.get_color_layer(view)

		var color_uniform = RDUniform.new()
		color_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		color_uniform.binding = 0
		color_uniform.add_id(color_image)
		var uniform_set = UniformSetCacheRD.get_cache(shader, 0, [color_uniform])

		var compute_list = rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		rd.compute_list_set_push_constant(compute_list, constants.to_byte_array(), constants.size()*4)
		rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
		rd.compute_list_end()
