class_name QualitySettingsBenchmark
extends Node

@export_category("Configuration")
@export var quality_settings_resources: Array[QualitySettingsResource] = []
@export var viewport: SubViewport
@export var world_environment: WorldEnvironment

@export_category("Benchmark Settings")
@export var number_of_frames = 10
@export var render_time_threshold = 0.017 # Approximately 60 fps 

@onready var benchmark_results : Array :
	get:
		return _benchmark_results

@onready var _benchmark_results = []


func benchmark() -> QualitySettingsResource:
	_benchmark_results.clear()
#	print(RenderingServer.viewport_getrender_info()get_tree().root.render_target_update_mode)
	var window_viewport_rid = get_tree().root.get_viewport_rid()
#	RenderingServer.viewport_set_clear_mode(window_viewport_rid, RenderingServer.VIEWPORT_CLEAR_NEVER)
	RenderingServer.viewport_set_update_mode(window_viewport_rid,RenderingServer.VIEWPORT_UPDATE_DISABLED)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	for settings in quality_settings_resources:
		settings.apply_settings(viewport, world_environment.environment)
		var avg_render_time = 0.0
		
		# force rendering one frame before test
		RenderingServer.force_draw(false)
		await RenderingServer.frame_post_draw # not sure if this helps?
		
		print("======= TEST: %s =======", settings.to_string())
		for i in range(number_of_frames):
			var timestamp = Time.get_unix_time_from_system()
			RenderingServer.force_draw(false)
			var render_time := Time.get_unix_time_from_system() - timestamp
			print("Rendering time: %f", render_time)
			
			# returned values have too much variance, even when render_time is low
			if render_time > render_time_threshold:
				avg_render_time = -1.0
				break
			avg_render_time += render_time
			await RenderingServer.frame_post_draw
		
		if avg_render_time != -1.0:
			avg_render_time /= number_of_frames
		_benchmark_results.append(avg_render_time)
	
	print(_benchmark_results)
	
#	RenderingServer.viewport_set_clear_mode(window_viewport_rid, RenderingServer.VIEWPORT_CLEAR_ALWAYS)
	RenderingServer.viewport_set_update_mode(window_viewport_rid, RenderingServer.VIEWPORT_UPDATE_ALWAYS)
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	
	return QualitySettingsResource.new()
