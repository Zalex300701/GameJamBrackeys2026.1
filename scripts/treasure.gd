extends StaticBody3D

@export var data: TreasureData

var digs_done: int = 0
var is_digging: bool = false
var is_collected: bool = false

@onready var mesh = $TreasureModel
@onready var detection_area = $DetectionArea

var spawn_position: Vector3

func _ready():
	add_to_group("treasure")
	spawn_position = global_position
	
	if data and data.scene_3d:
		var model = data.scene_3d.instantiate()
		$TreasureModel.add_child(model)
	mesh.visible = false
	mesh.position = Vector3(0, -2, 0)

func receive_dig():
	if is_collected:
		return
	digs_done += 1

	var progress = float(digs_done) / float(data.digs_required)
	mesh.visible = true
	var tween = create_tween()
	var target_y = lerp(0.0, 0.325, progress)
	tween.tween_property(mesh, "position", Vector3(0, target_y, 0), 0.15)
	
	if digs_done >= data.digs_required:
		is_collected = true
		get_tree().get_first_node_in_group("player").add_inventory_item(data, self)
		visible = false
		detection_area.monitoring = false

func reset_treasure():
	# Réinitialise le trésor à son état initial
	is_collected = false
	digs_done = 0
	visible = true
	global_position = spawn_position
	
	mesh.position = Vector3(0, -2, 0)
	mesh.visible = false
	
	# Réactive la détection
	detection_area.monitoring = true

	# Cache le mesh si nécessaire
	if has_node("TreasureModel"):
		var model = get_node("TreasureModel")
		for child in model.get_children():
			if child is MeshInstance3D:
				child.visible = false
