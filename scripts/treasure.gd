extends StaticBody3D

@export var treasure_name: String = "Fragment Alien"
@export var treasure_value: int = 100
@export var digs_required: int = 5

var digs_done: int = 0
var is_digging: bool = false
var is_collected: bool = false

@onready var mesh = $TreasureModel

func _ready():
	mesh.visible = true

func receive_dig():
	if is_collected:
		return
	digs_done += 1
	# Révèle progressivement le mesh
	var progress = float(digs_done) / float(digs_required)
	mesh.visible = true
	var tween = create_tween()
	tween.tween_property(mesh, "scale", Vector3.ONE * progress, 0.15)
	if digs_done >= digs_required:
		_collect()

func _collect():
	is_collected = true
	var tween = create_tween()
	# Petite animation de collecte vers le haut
	tween.tween_property(mesh, "position", position + Vector3(0, 1, 0), 0.3)
	tween.tween_property(mesh, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(_on_collect_done)

func _on_collect_done():
	# Envoie l'info au joueur/inventaire
	#get_tree().get_first_node_in_group("player").add_to_inventory(treasure_name, treasure_value)
	queue_free()
