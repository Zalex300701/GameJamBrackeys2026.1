extends CharacterBody3D

var is_chasing: bool = false
var chase_speed: float = 4.0
var player = null
var cinematic_mode: bool = false

@onready var audio = $AudioStreamPlayer3D

func _ready():
	add_to_group("ghost")

func start_chase():
	is_chasing = true
	player = get_tree().get_first_node_in_group("player")

func start_cinematic():
	cinematic_mode = true
	is_chasing = false
	player = get_tree().get_first_node_in_group("player")

	# Coupe l'audio
	if audio:
		audio.stop()

func _physics_process(delta):
	if not player:
		return
	
	# Mode cinématique : approche lente sans tuer
	if cinematic_mode:
		var direction = (player.global_position + Vector3(0, -1, 0) - global_position).normalized()
		velocity = direction * 1.0  # vitesse lente
		look_at(player.global_position + Vector3(0, -1, 0), Vector3.UP)
		rotation.y += deg_to_rad(180)
		move_and_slide()
		# Ne tue PAS le joueur en mode cinématique
		return
	
	# Mode normal (chase)
	if not is_chasing:
		return
	
	var direction = (player.global_position + Vector3(0, -1, 0) - global_position).normalized()
	velocity = direction * chase_speed
	look_at(player.global_position + Vector3(0, -1, 0), Vector3.UP)
	rotation.y += deg_to_rad(180)
	move_and_slide()
	
	if global_position.distance_to(player.global_position) < 1.5:
		player._die()
		await get_tree().create_timer(2.0).timeout
		queue_free()

func stop_chase():
	is_chasing = false
	for child in get_children():
		if child is MeshInstance3D:
			var tween = create_tween()
			tween.tween_property(child, "transparency", 1.0, 1.0)
	await get_tree().create_timer(1.0).timeout
	queue_free()
