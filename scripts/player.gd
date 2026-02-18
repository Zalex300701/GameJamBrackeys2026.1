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
@onready var detector = $Detector
var dig_cooldown: float = 0.0
const DIG_COOLDOWN: float = 0.3

# Grinding
var total_dollars: int = 5000
var is_grinding: bool = false

var is_dead: bool = false
var sos_fragments: int = 0
var has_beacon: bool = false
var beacon_instance = null

func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if particles_node:
		remote_transform_3d.set_remote_node(particles_node.get_path())

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	if event.is_action_pressed("ui_cancel") and not is_dead:
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

func add_inventory_item(treasure: TreasureData):
	inventory_items.append(treasure)
	hud.add_to_list_item(treasure)
	
	if treasure.is_sos_fragment:
		sos_fragments += 1
		hud.update_sos_count(sos_fragments)
		if sos_fragments >= 3:
			print("Tous les fragments collectés ! Construisez la balise !")

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
	hud.remove_last_of(treasure.treasure_name)
	await get_tree().create_timer(2.5).timeout
	total_dollars += treasure.value
	hud.update_dollars(total_dollars)
	await get_tree().create_timer(0.5).timeout
	_grind_next(items, index + 1)

func grind_all():
	if is_grinding or inventory_items.is_empty():
		return
	is_grinding = true
	var items_to_grind = []
	for item in inventory_items:
		if not item.is_sos_fragment:
			items_to_grind.append(item)
	
	if items_to_grind.is_empty():
		is_grinding = false
		print("Rien à broyer !")
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
	sos_fragments = 0  # retire les fragments
	hud.update_sos_count(0)
	hud.show_beacon_held()

	# Instancie un modèle 3D de balise dans les mains
	beacon_instance = preload("res://assets/models/treasures/american_ball_model.glb").instantiate()
	$Player_Head/Player_Camera3D.add_child(beacon_instance)
	beacon_instance.position = Vector3(0.3, -0.2, -0.5)

func _handle_beacon_placement():
	if not has_beacon:
		return
	
	var shelter = get_tree().get_first_node_in_group("shelter")
	if not shelter:
		return
	
	var distance = global_position.distance_to(shelter.global_position)
	if distance < 5.0:
		hud.show_interact_prompt("Eloignez-vous du shelter!")
		return
	
	hud.show_interact_prompt("[E] Poser la balise")
	
	if Input.is_action_just_pressed("interact"):
		_place_beacon()

func _place_beacon():
	has_beacon = false
	beacon_instance.queue_free()
	
	# Instancie la balise dans le monde
	var beacon_world = preload("res://scenes/beacon_placed.tscn").instantiate()
	get_parent().add_child(beacon_world)
	beacon_world.global_position = global_position + head.transform.basis.z * -2.0  # 2m devant
	
	hud.hide_beacon_held()
