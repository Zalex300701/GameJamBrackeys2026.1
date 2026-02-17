extends StaticBody3D

@export var data: TreasureData

var digs_done: int = 0
var is_digging: bool = false
var is_collected: bool = false

@onready var mesh = $TreasureModel

func _ready():
	if data and data.scene_3d:
		var model = data.scene_3d.instantiate()
		$TreasureModel.add_child(model)
	mesh.visible = false

func receive_dig():
	if is_collected:
		return
	digs_done += 1
	# Révèle progressivement le mesh
	var progress = float(digs_done) / float(data.digs_required)
	mesh.visible = true
	var tween = create_tween()
	var target_y = lerp(0.0, 0.25, progress)
	tween.tween_property(mesh, "position", Vector3(0, target_y, 0), 0.15)
	if digs_done >= data.digs_required:
		get_tree().get_first_node_in_group("player").add_inventory_item(data)
		queue_free()
