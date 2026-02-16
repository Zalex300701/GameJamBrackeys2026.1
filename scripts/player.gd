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

@onready var pause_menu := $PauseMenu
@onready var hud = get_tree().get_first_node_in_group("hud")
var inventory_items = {}

# Oxygen Module
var oxygen: float = 100.0
var in_shelter: bool = false
const OXYGEN_DRAIN = 1.5
const OXYGEN_REGEN = 20.0

# Detector
@onready var detector = $Detector
var dig_cooldown: float = 0.0
const DIG_COOLDOWN: float = 0.3

func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	if event.is_action_pressed("ui_cancel"):
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
	if in_shelter:
		oxygen = min(100.0, oxygen + OXYGEN_REGEN * delta)
	else:
		oxygen = max(0.0, oxygen - OXYGEN_DRAIN * delta)
	
	if hud:
		hud.update_oxygen(oxygen)
	
	# Digging
	_handle_digging(delta)

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
	if inventory_items.has(treasure.treasure_name):
		var entry = inventory_items[treasure.treasure_name]
		entry.count += 1
		entry.label.text = treasure.treasure_name + " x" + str(entry.count)
	else:
		var item = HBoxContainer.new()
		
		var icon = TextureRect.new()
		icon.texture = treasure.icon
		icon.custom_minimum_size = Vector2(32, 32)
		item.add_child(icon)
		
		var label = Label.new()
		label.text = treasure.treasure_name
		item.add_child(label)
		
		hud.add_to_list(item)
		inventory_items[treasure.treasure_name] = {
			"hbox": item,
			"label": label,
			"count": 1
		}
