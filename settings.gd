extends Control

# Window project settings:
#  - Stretch mode is set to `canvas_items` (`2d` in Godot 3.x)
#  - Stretch aspect is set to `expand`
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var camera := $Node3D/Camera3D
@onready var fps_label := $FPSLabel
@onready var resolution_label := $ResolutionLabel

@export var high_quality_settings: QualitySettingsResource
@export var medium_quality_settings: QualitySettingsResource
@export var low_quality_settings: QualitySettingsResource
@onready var quality_settings: QualitySettingsResource

@onready var quality_low_label: Label = %ResultLowLabel
@onready var quality_medium_label: Label = %ResultMediumLabel
@onready var quality_high_label: Label = %ResultHighLabel

@onready var benchmark_button: Button = %BenchmarkButton
@onready var apply_low_button: Button = %ApplyLowButton
@onready var apply_medium_button: Button = %ApplyMediumButton
@onready var apply_high_button: Button = %ApplyHighButton


func _ready() -> void:
	quality_settings = low_quality_settings
	
	get_viewport().connect(&"size_changed", update_resolution_label)
	update_resolution_label()
	
	var viewport := get_tree().root
	var environment := world_environment.environment
	
	quality_settings.apply_settings(viewport, environment)
	
	benchmark_button.pressed.connect(_on_benchmark_pressed)
	apply_low_button.pressed.connect(low_quality_settings.apply_settings.bind(viewport, environment))
	apply_medium_button.pressed.connect(medium_quality_settings.apply_settings.bind(viewport, environment))
	apply_high_button.pressed.connect(high_quality_settings.apply_settings.bind(viewport, environment))


func _on_benchmark_pressed() -> void:
	var benchmark_node = load("res://QualitySettingsBenchmarker/Benchmark1.tscn").instantiate()
	add_child(benchmark_node)
	benchmark_node.benchmark()
	_set_result_label(benchmark_node.benchmark_results[0], quality_low_label)
	_set_result_label(benchmark_node.benchmark_results[1], quality_medium_label)
	_set_result_label(benchmark_node.benchmark_results[2], quality_high_label)
	quality_settings.apply_settings(get_tree().root, world_environment.environment)
	benchmark_node.queue_free()


func _set_result_label(result: Dictionary, label: Label) -> void:
	label.text = ""
	for key in result.keys():
		if result[key] is float:
			label.text += "%s:%.3fms\n" % [key, result[key] * 1000.0]
		else:
			label.text += "%s:%s\n" % [key, result[key]]
	label.text += "expected_fps: %.3f" % (1.0/result["device_timestamp_avg"])


func _process(delta: float) -> void:
	fps_label.text = "%d FPS (%.2f mspf)" % [Engine.get_frames_per_second(), 1000.0 / Engine.get_frames_per_second()]


func update_resolution_label() -> void:
	var viewport_render_size = get_viewport().size * get_viewport().scaling_3d_scale
	resolution_label.text = "3D viewport resolution: %d × %d (%d%%)" \
			% [viewport_render_size.x, viewport_render_size.y, round(get_viewport().scaling_3d_scale * 100)]


func _on_HideShowButton_toggled(show_settings: bool) -> void:
	# Option to hide the settings so you can see the changes to the 3d world better.
	var button := $HideShowButton
	var settings_menu := $SettingsMenu
	if show_settings:
		button.text = "Hide settings"
	else:
		button.text = "Show settings"
	settings_menu.visible = show_settings


#func _on_ui_scale_option_button_item_selected(index: int) -> void:
#	quality_settings.ui_scale = index
#	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_quality_slider_value_changed(value: float) -> void:
	quality_settings.scaling_3d_value = value
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_filter_option_button_item_selected(index: int) -> void:
	if index == 0:
		quality_settings.scaling_3d_mode = quality_settings.SCALING_3D_MODE.BILENAR
	elif index == 1:
		quality_settings.scaling_3d_mode = quality_settings.SCALING_3D_MODE.FSR
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_vsync_option_button_item_selected(index: int) -> void:
	if index == 0:
		quality_settings.vsync_mode = quality_settings.VSYNC_MODE.DISABLED
	elif index == 1:
		quality_settings.vsync_mode = quality_settings.VSYNC_MODE.ADAPTIVE
	elif index == 2:
		quality_settings.vsync_mode = quality_settings.VSYNC_MODE.ENABLED
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_aa_option_button_item_selected(index: int) -> void:
	if index == 0: # Disabled
		quality_settings.msaa_3d_mode = quality_settings.MSAA_3D_MODE.DISABLED
	elif index == 1: # 2×
		quality_settings.msaa_3d_mode = quality_settings.MSAA_3D_MODE.MSAA_2X
	elif index == 2: # 4×
		quality_settings.msaa_3d_mode = quality_settings.MSAA_3D_MODE.MSAA_4X
	elif index == 3: # 8×
		quality_settings.msaa_3d_mode = quality_settings.MSAA_3D_MODE.MSAA_8X
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_fxaa_option_button_item_selected(index: int) -> void:
	quality_settings.fxaa_enabled = index == 1
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


#func _on_fullscreen_option_button_item_selected(index: int) -> void:
#	quality_settings.fullscreen_enabled = index == 1
#	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_ss_reflections_option_button_item_selected(index: int) -> void:
	if index == 0:
		quality_settings.ss_reflection_quality = quality_settings.SS_REFLECTION_QUALITY.DISABLED
	elif index == 1:
		quality_settings.ss_reflection_quality = quality_settings.SS_REFLECTION_QUALITY.LOW
	elif index == 2:
		quality_settings.ss_reflection_quality = quality_settings.SS_REFLECTION_QUALITY.MEDIUM
	elif index == 3:
		quality_settings.ss_reflection_quality = quality_settings.SS_REFLECTION_QUALITY.HIGH
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_ssao_option_button_item_selected(index: int) -> void:
	if index == 0:
		quality_settings.ssao_quality = quality_settings.SSAO_QUALITY.DISABLED
	elif index == 1:
		quality_settings.ssao_quality = quality_settings.SSAO_QUALITY.VERY_LOW
	elif index == 2:
		quality_settings.ssao_quality = quality_settings.SSAO_QUALITY.LOW
	elif index == 3:
		quality_settings.ssao_quality = quality_settings.SSAO_QUALITY.MEDIUM
	elif index == 4:
		quality_settings.ssao_quality = quality_settings.SSAO_QUALITY.HIGH
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_ssil_option_button_item_selected(index: int) -> void:
	if index == 0:
		quality_settings.ssil_quality = quality_settings.SSIL_QUALITY.DISABLED
	elif index == 1:
		quality_settings.ssil_quality = quality_settings.SSIL_QUALITY.VERY_LOW
	elif index == 2:
		quality_settings.ssil_quality = quality_settings.SSIL_QUALITY.LOW
	elif index == 3:
		quality_settings.ssil_quality = quality_settings.SSIL_QUALITY.MEDIUM
	elif index == 4:
		quality_settings.ssil_quality = quality_settings.SSIL_QUALITY.HIGH
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_sdfgi_option_button_item_selected(index: int) -> void:
	if index == 0: # Disabled
		quality_settings.sdfgi_quality = quality_settings.SDFGI_QUALITY.DISABLED
	if index == 1: # Low
		quality_settings.sdfgi_quality = quality_settings.SDFGI_QUALITY.LOW
	if index == 2: # High
		quality_settings.sdfgi_quality = quality_settings.SDFGI_QUALITY.HIGH
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_glow_option_button_item_selected(index: int) -> void:
	if index == 0: # Disabled
		quality_settings.glow_quality = quality_settings.GLOW_QUALITY.DISABLED
	if index == 1: # Low
		quality_settings.glow_quality = quality_settings.GLOW_QUALITY.LOW
	if index == 2: # High
		quality_settings.glow_quality = quality_settings.GLOW_QUALITY.HIGH
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_volumetric_fog_option_button_item_selected(index: int) -> void:
	if index == 0: # Disabled
		quality_settings.volumetric_fog_quality = quality_settings.VOLUMETRIC_FOG_QUALITY.DISABLED
	if index == 1: # Low
		quality_settings.volumetric_fog_quality = quality_settings.VOLUMETRIC_FOG_QUALITY.LOW
	if index == 2: # High
		quality_settings.volumetric_fog_quality = quality_settings.VOLUMETRIC_FOG_QUALITY.HIGH
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_brightness_slider_value_changed(value: float) -> void:
	quality_settings.brightness_value = value
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_contrast_slider_value_changed(value: float) -> void:
	quality_settings.contrast_value = value
	quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _on_saturation_slider_value_changed(value: float) -> void:
	quality_settings.saturation_value = value
	quality_settings.apply_settings(get_tree().root, world_environment.environment)
