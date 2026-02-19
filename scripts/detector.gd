extends Node3D

const BIP_MIN_INTERVAL: float = 2.0
const BIP_MAX_INTERVAL: float = 0.005

var bip_timer: float = 0.0
var nearest_treasure = null
var dig_range: float = 1.75
var detector_level: int = 1

const DETECTION_RANGES = {
	1: 20.0,
	2: 50.0,
	3: 100.0
}

@onready var bip_sound = $BipSound
@onready var distance_label = $DistanceLabel
@onready var detector_level_label: Label3D = $DetectorLevelLabel
@onready var range_label: Label3D = $RangeLabel

func _ready():
	if distance_label:
		distance_label.text = "---"
	if range_label:
		range_label.text = "RANGE: " + str(DETECTION_RANGES[detector_level]) + "M"

func _process(delta):
	_scan()
	_update_bip(delta)
	_update_display()

func _scan():
	var all_treasures = get_tree().get_nodes_in_group("treasure")
	var accessible_treasures = []
	
	for t in all_treasures:
		if not t.is_collected and t.data.required_detector_level <= detector_level:
			accessible_treasures.append(t)
	
	var nearest = null
	var min_dist = DETECTION_RANGES[detector_level]
	for t in accessible_treasures:
		var d = global_position.distance_to(t.global_position)
		if d < min_dist:
			min_dist = d
			nearest = t
	
	nearest_treasure = nearest

func _update_display():
	if not distance_label:
		return
	
	if nearest_treasure:
		var dist = global_position.distance_to(nearest_treasure.global_position)
		distance_label.text = "%.1fm" % dist  # affiche avec 1 décimale
	
		# Change la couleur selon la distance
		if dist < 2.0:
			distance_label.modulate = Color.RED  # très proche
		elif dist < 5.0:
			distance_label.modulate = Color.YELLOW  # proche
		else:
			distance_label.modulate = Color.GREEN  # loin
	else:
		distance_label.text = "---"
		distance_label.modulate = Color.GREEN

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
	if nearest_treasure and global_position.distance_to(nearest_treasure.global_position) < dig_range:
		return nearest_treasure
	return null

func upgrade():
	if detector_level < 3:
		detector_level += 1
		detector_level_label.text = "DETECTOR LEVEL: " + str(detector_level)
		range_label.text = "RANGE: " + str(DETECTION_RANGES[detector_level]) + "M"
		return true
	return false

func get_level() -> int:
	return detector_level
