extends CharacterBody3D

var speed
const WALK_SPEED = 3.5
const SPRINT_SPEED = 5.0
const SENSITIVITY = 0.005

const BOB_FREQ = 3.5
const BOB_AMP = 0.06
var t_bob = 0.0

const BASE_FOV = 75
const FOV_CHANGE = 2.0

var gravity = 9.8

@onready var head: Node3D = $Player_Head
@onready var camera: Camera3D = $Player_Head/Player_Camera3D
@export var particles_node: GPUParticles3D
@onready var remote_transform_3d: RemoteTransform3D = $RemoteTransform3D

@onready var pause_menu := $PauseMenu
@onready var hud = get_tree().get_first_node_in_group("hud")
var inventory_items = []

# Oxygen Module
var oxygen: float = 100.0
var in_shelter: bool = false
const OXYGEN_DRAIN = 1.5
const OXYGEN_REGEN = 20.0

# Detector
@onready var detector = $Player_Head/Player_Camera3D/Detector
var dig_cooldown: float = 0.0
const DIG_COOLDOWN: float = 0.3

# Grinding
var total_dollars: int = 5000
var is_grinding: bool = false

var is_dead: bool = false
var sos_fragments: int = 3
var has_beacon: bool = false
var beacon_instance = null
var can_pause: bool = true

@onready var computer = null

var beacon_preview = null
var preview_mat_valid = preload("res://assets/materials/beacon_preview_valid.tres")
var preview_mat_invalid = preload("res://assets/materials/beacon_preview_invalid.tres")

@onready var dig: AudioStreamPlayer = $dig

func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if particles_node:
		remote_transform_3d.set_remote_node(particles_node.get_path())
	
	await get_tree().process_frame
	computer = get_tree().get_first_node_in_group("pc")
	if computer:
		await get_tree().create_timer(2.0).timeout
		computer.play_dialog("Welcome to the Cleaning base 2779. Thank you for contributing to this wonderful project.", preload("res://assets/sounds/voices/Line1.ogg"))

func _input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	if event.is_action_pressed("ui_cancel"):
		if can_pause and not is_dead:
			pause_menu.toggle()
			get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 10.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 10.0)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()
	
	# Oxygen
	if not is_dead:
		if in_shelter:
			oxygen = min(100.0, oxygen + OXYGEN_REGEN * delta)
		else:
			oxygen = max(0.0, oxygen - OXYGEN_DRAIN * delta)
		
		if hud:
			hud.update_oxygen(oxygen)
		
		if oxygen <= 0.0:
			_die()
		
		_handle_digging(delta)
		_handle_interaction()
		
		if has_beacon:
			_handle_beacon_placement()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func enter_shelter():
	in_shelter = true

func leave_shelter():
	in_shelter = false

func _handle_digging(delta):
	dig_cooldown -= delta
	if Input.is_action_just_pressed("dig") and dig_cooldown <= 0.0:
		var target = detector.get_diggable_target()
		if target:
			target.receive_dig()
			dig_cooldown = DIG_COOLDOWN
			dig.play()

func add_inventory_item(treasure: TreasureData):
	inventory_items.append(treasure)
	hud.add_to_list_item(treasure)
	
	if treasure.is_sos_fragment:
		sos_fragments += 1
	
	if treasure.is_ghost:
		var ghost_scene = preload("res://scenes/ghost.tscn")
		var ghost = ghost_scene.instantiate()
		get_tree().root.add_child(ghost)
		var player = get_tree().get_first_node_in_group("player")
		var random_angle = randf() * TAU  # angle aléatoire
		var spawn_distance = randf_range(10.0, 15.0)
		var offset = Vector3(cos(random_angle), 0, sin(random_angle)) * spawn_distance
		ghost.global_position = player.global_position + offset
		ghost.start_chase()

func _handle_interaction():
	if has_beacon:
		return
	
	var ray = $Player_Head/Player_Camera3D/Player_RayCast3D
	
	if ray.is_colliding():
		var hit = ray.get_collider()
		if hit.has_method("interact"):
			# Affiche le prompt selon l'objet
			if hit.has_method("get_interact_text"):
				hud.show_interact_prompt(hit.get_interact_text())
			else:
				hud.show_interact_prompt("[E] Interagir")
			
			if Input.is_action_just_pressed("interact"):
				hit.interact(self)
		else:
			hud.hide_interact_prompt()
	else:
		hud.hide_interact_prompt()

func _grind_next(items: Array, index: int):
	if index >= items.size():
		is_grinding = false
		return
	var treasure = items[index]
	
	var grinder = get_tree().get_first_node_in_group("grinder")
	if grinder:
		grinder.spawn_and_grind_treasure(treasure)
		await grinder.grind_finished
	
	hud.remove_last_of(treasure.treasure_name)
	total_dollars += treasure.value
	hud.update_dollars(total_dollars)
	await get_tree().create_timer(0.5).timeout
	_grind_next(items, index + 1)

func grind_all():
	if is_grinding or inventory_items.is_empty():
		return
	
	if computer:
		var grind_dialogues = [
			{"text": "Good job.", "audio": preload("res://assets/sounds/voices/Line2.ogg")},
			{"text": "Well done.", "audio": preload("res://assets/sounds/voices/Line3.ogg")},
			{"text": "Excellent work.", "audio": preload("res://assets/sounds/voices/Line4.ogg")},
			{"text": "Remarkable results.", "audio": preload("res://assets/sounds/voices/Line5.ogg")}
			]
		var random_dialog = grind_dialogues[randi() % grind_dialogues.size()]
		computer.play_dialog(random_dialog.text, random_dialog.audio)
	
	is_grinding = true
	var items_to_grind = []
	for item in inventory_items:
		if not item.is_sos_fragment:
			items_to_grind.append(item)
	
	if items_to_grind.is_empty():
		is_grinding = false
		print("Nothing to grind")
		return
	
	inventory_items = inventory_items.filter(func(i): return i.is_sos_fragment)
	_grind_next(items_to_grind, 0)

func _die():
	is_dead = true
	set_physics_process(false)
	hud.hide_hud()
	hud.show_death()
	await get_tree().create_timer(2.0).timeout
	_respawn()

func _respawn():
	oxygen = 100.0
	
	var shelter = get_tree().get_first_node_in_group("shelter")
	if shelter:
		global_position = shelter.get_node("SpawnPoint").global_position
	
	var grinder = get_tree().get_first_node_in_group("grinder")
	if grinder:
		var direction = (global_position - grinder.global_position).normalized()
		var target_rotation = atan2(direction.x, direction.z)
		head.rotation.y = target_rotation
		camera.rotation.x = 0
	
	velocity = Vector3.ZERO
	hud.hide_death()
	grinder.play_death_animation()
	await hud.death_fade_finished
	hud.show_hud()
	is_dead = false
	set_physics_process(true)

func give_beacon():
	has_beacon = true
	sos_fragments = 0
	detector.visible = false
	
	# Fait disparaître la station de construction
	var station = get_tree().get_first_node_in_group("sos_station")
	if station:
		var tween = create_tween()
		tween.tween_callback(station.queue_free)
	
	# Preview
	beacon_preview = preload("res://assets/models/props/sos_beacon.glb").instantiate()
	get_parent().add_child(beacon_preview)

	# Applique le matériau vert par défaut
	_apply_preview_material(preview_mat_invalid)
	
	# Instancie un modèle 3D de balise dans les mains
	beacon_instance = preload("res://assets/models/props/sos_beacon.glb").instantiate()
	$Player_Head/Player_Camera3D.add_child(beacon_instance)
	beacon_instance.position = Vector3(0.3, -0.5, -0.5)

func _apply_preview_material(mat: Material):
	for child in beacon_preview.get_children():
		if child is MeshInstance3D:
			for i in range(child.mesh.get_surface_count()):
				child.set_surface_override_material(i, mat)

func _handle_beacon_placement():
	if not has_beacon or not beacon_preview:
		return
	
	var shelter = get_tree().get_first_node_in_group("shelter")
	if not shelter:
		return
	
	var preview_pos = global_position + head.transform.basis.z * -2.0
	preview_pos.y = 0
	beacon_preview.global_position = preview_pos
	
	# Vérifie la distance
	var distance = global_position.distance_to(shelter.global_position)
	var can_place = distance >= 15.0
	
	# Change le matériau
	if can_place:
		_apply_preview_material(preview_mat_valid)
		hud.show_interact_prompt("[E] Place SOS Beacon")
	else:
		_apply_preview_material(preview_mat_invalid)
		hud.hide_interact_prompt()
	
	if Input.is_action_just_pressed("interact") and can_place:
		_place_beacon()

func _place_beacon():
	has_beacon = false
	beacon_instance.queue_free()
	
	# Instancie la balise dans le monde
	var beacon_world = preload("res://scenes/beacon_placed.tscn").instantiate()
	get_parent().add_child(beacon_world)
	var pos = global_position + head.transform.basis.z * -2.0  # 2m devant
	pos.y = 0
	beacon_world.global_position = pos
