extends MeshInstance3D

@export var rotation_speed: float = 1.0  # tours par seconde

func _process(delta: float) -> void:
	rotate(Vector3(1, 0, 0), rotation_speed * delta)
