class_name QualitySettingsBenchmark
extends Node

@export_category("Configuration")
@export var quality_settings_resources: Array[QualitySettingsResource] = []
@export var viewport: SubViewport
@export var world_environment: WorldEnvironment

@export_category("Benchmark Settings")
@export var number_of_frames = 10
@export var target_render_time = 0.0166 # Approximately 60 fps 

@onready var benchmark_results : Array :
	get:
		return _benchmark_results

@onready var _benchmark_results = []


func benchmark() -> QualitySettingsResource:
	_benchmark_results.clear()
	var window_viewport_rid = get_tree().root.get_viewport_rid()
	RenderingServer.viewport_set_update_mode(window_viewport_rid,RenderingServer.VIEWPORT_UPDATE_DISABLED)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	for settings in quality_settings_resources:
		settings.apply_settings(viewport, world_environment.environment)
		var avg_render_time = 0.0
		
		# force rendering one frame before test
		RenderingServer.force_draw(false)
		
		var RENDER_TIME_THRESHOLD := target_render_time * 10.0
		var rendering_device := RenderingServer.get_rendering_device()
		var last_device_timestamp := 0
		print("======= TEST: %s =======", settings.to_string())
		for i in range(number_of_frames):
			rendering_device.capture_timestamp("timestamp")
			var timestamp = Time.get_unix_time_from_system()
			RenderingServer.force_draw(false)
			var render_time := Time.get_unix_time_from_system() - timestamp
			var device_timestamp := rendering_device.get_captured_timestamp_gpu_time(0)
			var device_timestamp_diff := (device_timestamp - last_device_timestamp)/1000000000.0
			
			print("device_timestamp_diff: %f" % device_timestamp_diff)
			print("render_time: %fs" % render_time)
			
			last_device_timestamp = device_timestamp
			
			# too slow, no need to test further
			if render_time > RENDER_TIME_THRESHOLD:
				avg_render_time = -1.0
				break
			
			avg_render_time += render_time
		
		if avg_render_time != -1.0:
			avg_render_time /= number_of_frames
		_benchmark_results.append(avg_render_time)
	
	print(_benchmark_results)
	
	RenderingServer.viewport_set_update_mode(window_viewport_rid, RenderingServer.VIEWPORT_UPDATE_ALWAYS)
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	
	return QualitySettingsResource.new()
