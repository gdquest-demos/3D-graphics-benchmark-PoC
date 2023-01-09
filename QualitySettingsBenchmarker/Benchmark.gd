class_name QualitySettingsBenchmark
extends Node

@export_category("Configuration")
@export var quality_settings_resources: Array[QualitySettingsResource] = []
@export var viewport: Viewport
@export var world_environment: WorldEnvironment

@export_category("Benchmark Settings")
@export var target_render_time = 0.0166 # Approximately 60 fps

@onready var benchmark_results : Array :
	get:
		return _benchmark_results

@onready var _benchmark_results = []


func benchmark() -> void:
	_benchmark_results.clear()
	
	var rendering_device := RenderingServer.get_rendering_device()
	var window_viewport_rid = get_tree().root.get_viewport_rid()
	var benchmark_viewport_rid = viewport.get_viewport_rid()
	
	RenderingServer.viewport_set_update_mode(window_viewport_rid, RenderingServer.VIEWPORT_UPDATE_DISABLED)
	RenderingServer.viewport_set_update_mode(benchmark_viewport_rid, RenderingServer.VIEWPORT_UPDATE_ALWAYS)
	
	for settings in quality_settings_resources:
		settings.apply_settings(viewport, world_environment.environment)

		var last_device_timestamp := 0
		var RENDER_TIME_THRESHOLD := 0.5 #target_render_time * 10.0
		var FRAME_DELAY := rendering_device.get_frame_delay()
		
		var benchmark_result := {
			&"failed": false,
			&"unix_time_avg": 0.0,
			&"device_timestamp_avg": 0.0,
			&"unix_time_variance": 0.0,
			&"device_timestamp_variance": 0.0,
		}
		
		print("")
		print("==== FRAME DELAY ====")
		print("")
		
		for i in range(FRAME_DELAY + 1):
			var frame := _capture_render_time(rendering_device, false)
			if frame[&"unix_time_diff"] > RENDER_TIME_THRESHOLD:
				benchmark_result[&"failed"] = true
				break
		
		print("")
		print("==== BENCHMARK ====")
		print("")
		
		var frames := []
		
		if not benchmark_result[&"failed"]:
			for i in range(10):
				var frame := _capture_render_time(rendering_device, true)
				if frame[&"unix_time_diff"] > RENDER_TIME_THRESHOLD:
					benchmark_result[&"failed"] = true
					break
				frames.append(frame)

		if not benchmark_result[&"failed"]:
			var unix_time_total := 0.0
			var device_timestamp_total := 0.0
			
			for frame in frames:
				unix_time_total += frame[&"unix_time_diff"]
				device_timestamp_total += frame[&"device_timestamp_diff"]
			
			var unix_time_avg := unix_time_total / 10.0
			var device_timestamp_avg := device_timestamp_total / 10.0
			
			var unix_time_variance := 0.0
			var device_timestamp_variance := 0.0
			
			for frame in frames:
				var variance_diff = (frame[&"unix_time_diff"] - unix_time_avg)
				unix_time_variance += variance_diff * variance_diff
				variance_diff = (frame[&"device_timestamp_diff"] - device_timestamp_avg)
				device_timestamp_variance += variance_diff * variance_diff
			
			unix_time_variance /= 10.0
			device_timestamp_variance /= 10.0
			
			benchmark_result[&"unix_time_avg"] = unix_time_avg
			benchmark_result[&"device_timestamp_avg"] = device_timestamp_avg
			benchmark_result[&"unix_time_variance"] = unix_time_variance
			benchmark_result[&"device_timestamp_variance"] = device_timestamp_variance
		
		_benchmark_results.append(benchmark_result)
	
	RenderingServer.viewport_set_update_mode(window_viewport_rid, RenderingServer.VIEWPORT_UPDATE_ALWAYS)
	RenderingServer.viewport_set_update_mode(benchmark_viewport_rid, RenderingServer.VIEWPORT_UPDATE_DISABLED)


func _capture_render_time(rendering_device: RenderingDevice, benchmark: bool) -> Dictionary:
	var timestamp := 0.0
	var last_device_timestamp := 0
	
	if benchmark:
		timestamp = Time.get_unix_time_from_system()
		last_device_timestamp = rendering_device.get_captured_timestamp_gpu_time(0)
	
	rendering_device.capture_timestamp("timestamp")
	RenderingServer.force_draw(false)
	
	var unix_time_diff := 0.0
	var device_timestamp_diff = 0.0
	
	if benchmark:
		unix_time_diff = Time.get_unix_time_from_system() - timestamp
		var device_timestamp := rendering_device.get_captured_timestamp_gpu_time(0)
		device_timestamp_diff = (device_timestamp - last_device_timestamp)/1000000000.0
	
	print("device_timestamp_diff: %fs" % device_timestamp_diff)
	print("unix_time_diff: %fs" % unix_time_diff)
	
	return {
		&"device_timestamp_diff": device_timestamp_diff,
		&"unix_time_diff": unix_time_diff,
	}
