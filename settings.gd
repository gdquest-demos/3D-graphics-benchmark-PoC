extends Control

# Window project settings:
#  - Stretch mode is set to `canvas_items` (`2d` in Godot 3.x)
#  - Stretch aspect is set to `expand`
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var camera := $Node3D/Camera3D
@onready var fps_label := $FPSLabel

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
