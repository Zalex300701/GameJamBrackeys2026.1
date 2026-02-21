extends Node3D

@export var slide_distance: float = 2.0  # distance de glissement en mètres
@export var slide_direction: Vector3 = Vector3(0, 0, -1)  # direction (droite par défaut)
@export var animation_duration: float = 1.0

var is_open: bool = false
var is_animating: bool = false
var closed_position: Vector3
var open_position: Vector3

@onready var door_to_move: StaticBody3D = $Door_to_move

func _ready():
	print("Door ready, door_mesh: ", door_to_move)
	closed_position = door_to_move.position
	open_position = closed_position + (slide_direction.normalized() * slide_distance)
	print("Closed pos: ", closed_position)
	print("Open pos: ", open_position)

func toggle():
	print("Toggle appelé ! is_open: ", is_open, " is_animating: ", is_animating)
	
	if is_animating:
		print("Déjà en animation, ignoré")
		return

	is_animating = true

	if is_open:
		_close()
	else:
		_open()

func _open():
	print("Opening door...")
	var tween = create_tween()
	tween.tween_property(self, "position", open_position, animation_duration)
	await tween.finished
	print("Door opened!")
	is_open = true
	is_animating = false

func _close():
	print("Closing door...")
	var tween = create_tween()
	tween.tween_property(self, "position", closed_position, animation_duration)
	await tween.finished
	print("Door closed!")
	is_open = false
	is_animating = false
