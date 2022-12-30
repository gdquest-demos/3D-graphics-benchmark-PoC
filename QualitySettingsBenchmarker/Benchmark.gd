class_name QualitySettingsBenchmark
extends Node

@export var quality_settings_resources: Array[QualitySettingsResource] = []
@export var viewport: SubViewport
@export var world_environment: WorldEnvironment


func benchmark() -> QualitySettingsResource:
#	print(RenderingServer.viewport_getrender_info()get_tree().root.render_target_update_mode)
	var window_viewport_rid = get_tree().root.get_viewport_rid()
#	RenderingServer.viewport_set_clear_mode(window_viewport_rid, RenderingServer.VIEWPORT_CLEAR_NEVER)
	RenderingServer.viewport_set_update_mode(window_viewport_rid,RenderingServer.VIEWPORT_UPDATE_DISABLED)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	for settings in quality_settings_resources:
		settings.apply_settings(viewport, world_environment.environment)
		print("TEST: %s", settings.to_string())
		for i in range(10):
			var timestamp = Time.get_unix_time_from_system()
			RenderingServer.force_draw(false)
			var rendering_time := Time.get_unix_time_from_system() - timestamp
			print("Rendering time: %f", rendering_time)
	
#	RenderingServer.viewport_set_clear_mode(window_viewport_rid, RenderingServer.VIEWPORT_CLEAR_ALWAYS)
	RenderingServer.viewport_set_update_mode(window_viewport_rid, RenderingServer.VIEWPORT_UPDATE_ALWAYS)
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	
	return QualitySettingsResource.new()
