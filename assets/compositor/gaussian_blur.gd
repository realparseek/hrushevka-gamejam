@tool
extends CompositorEffect
class_name GaussianBlurEffect

var rd: RenderingDevice
var shader: RID
var pipeline: RID
var depth_sampler: RID

func _init() -> void:
	rd = RenderingServer.get_rendering_device()
	var shader_file: Resource = load("res://assets/shaders/gaussian_blur.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(shader)
	
	var sampler_state := RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	depth_sampler = rd.sampler_create(sampler_state)

func _render_callback(_effect_callback_type: int, render_data: RenderData) -> void:
	var rbuffers: RenderSceneBuffersRD = render_data.get_render_scene_buffers()
	var size: Vector2i = rbuffers.get_internal_size()
	
	var ucolor = RDUniform.new()
	ucolor.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	ucolor.binding = 0
	ucolor.add_id(rbuffers.get_color_texture())
	
	var udepth = RDUniform.new()
	udepth.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	udepth.binding = 1
	udepth.add_id(depth_sampler)
	udepth.add_id(rbuffers.get_depth_texture())
	
	var bindings: Array[RDUniform] = [ucolor, udepth]
	var groups: Vector3i = Vector3i(size.x, size.y, 1)
	var uniform_set: RID = rd.uniform_set_create(bindings, shader, 0)
	var compute_list: int = rd.compute_list_begin()
	
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
	rd.compute_list_end()
	
	rd.free_rid(uniform_set)
