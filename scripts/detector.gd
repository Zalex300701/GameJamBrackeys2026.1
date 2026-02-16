extends Node3D

const BIP_MIN_INTERVAL: float = 2.0
const BIP_MAX_INTERVAL: float = 0.005

var bip_timer: float = 0.0
var nearest_treasure = null
var dig_range: float = 2.0

@onready var bip_sound = $BipSound

func _process(delta):
	_scan()
	_update_bip(delta)

func _scan():
	var treasures = get_tree().get_nodes_in_group("treasure")
	print("Trésors trouvés : ", treasures.size())
	var nearest = null
	var min_dist = 10.0
	for t in treasures:
		if t.is_collected:
			continue
		var d = global_position.distance_to(t.global_position)
		print("Distance brute : ", d)
		if d < min_dist:
			min_dist = d
			nearest = t
	nearest_treasure = nearest

func _update_bip(delta):
	if nearest_treasure == null:
		return
	var dist = global_position.distance_to(nearest_treasure.global_position)
	var t = 1.0 - clamp(dist / 10.0, 0.0, 1.0)
	var interval = lerp(BIP_MIN_INTERVAL, BIP_MAX_INTERVAL, t)
	bip_timer -= delta
	if bip_timer <= 0.0:
		bip_sound.play()
		bip_timer = interval

func get_diggable_target() -> Node:
	if nearest_treasure:
		print("Distance au trésor : ", global_position.distance_to(nearest_treasure.global_position))
	else:
		print("Aucun trésor détecté")
	if nearest_treasure and global_position.distance_to(nearest_treasure.global_position) < dig_range:
		return nearest_treasure
	return null
