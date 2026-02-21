extends Camera3D

@export var breathe_speed: float = 1.0
@export var breathe_intensity: float = 0.02

var time_passed: float = 0.0
var original_position: Vector3

func _ready():
	original_position = position

func _process(delta):
	time_passed += delta * breathe_speed

	# Mouvement de respiration (sine wave)
	var offset_y = sin(time_passed) * breathe_intensity
	var offset_x = sin(time_passed * 0.7) * breathe_intensity * 0.5

	position = original_position + Vector3(offset_x, offset_y, 0)
