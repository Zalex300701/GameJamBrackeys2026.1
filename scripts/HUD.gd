extends CanvasLayer

@onready var hud_control = $HUD_Control
@onready var oxygen_bar = $HUD_Control/OxygenBar
@onready var inventory_list: VBoxContainer = $HUD_Control/InventoryList
@onready var dollars_label = $HUD_Control/DollarsLabel
@onready var death_screen = $Death_Control/DeathScreen
@onready var death_label = $Death_Control/DeathLabel
@onready var interact_label: Label = $HUD_Control/InteractLabel
var current_interact_text = ""
@onready var sos_label = $HUD_Control/SOSLabel
@onready var beacon_held_label = $HUD_Control/BeaconHeldLabel

var hud_items = {}

signal death_fade_finished

func _ready():
	death_screen.visible = false
	death_label.modulate.a = 0.0
	interact_label.modulate.a = 0.0
	interact_label.visible = false
	sos_label.text = "Fragments SOS: 0/3"
	beacon_held_label.visible = false

func update_oxygen(value: float):
	oxygen_bar.value = value

func add_to_list(item : HBoxContainer):
	inventory_list.add_child(item)

func update_dollars(amount: int):
	dollars_label.text = "$" + str(amount)

func remove_inventory_item(hbox: HBoxContainer):
	var tween = create_tween()
	tween.tween_property(hbox, "modulate:a", 0.0, 0.3)
	tween.tween_callback(hbox.queue_free)

func add_to_list_item(treasure: TreasureData):
	if hud_items.has(treasure.treasure_name):
		var entry = hud_items[treasure.treasure_name]
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
		inventory_list.add_child(item)
		hud_items[treasure.treasure_name] = {
			"hbox": item,
			"label": label,
			"count": 1
		}

func remove_last_of(treasure_name: String):
	if not hud_items.has(treasure_name):
		return
	var entry = hud_items[treasure_name]
	if entry.count > 1:
		entry.count -= 1
		entry.label.text = treasure_name + " x" + str(entry.count)
	else:
		remove_inventory_item(entry.hbox)
		hud_items.erase(treasure_name)

func show_death():
	death_screen.visible = true
	death_label.modulate.a = 0.0
	var tween = create_tween()
	# Fade in du fond noir
	tween.tween_property(death_screen, "color:a", 1.0, 1.0)
	tween.tween_property(death_label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(2.0)
	
func hide_death():
	var tween = create_tween()
	tween.tween_property(death_label, "modulate:a", 0.0, 2.0)
	tween.tween_property(death_screen, "color:a", 0.0, 1.0)
	tween.tween_callback(func(): 
		death_screen.visible = false
		death_fade_finished.emit()
	)

func hide_hud():
	var tween = create_tween()
	tween.tween_property(hud_control, "modulate:a", 0.0, 0.5)

func show_hud():
	var tween = create_tween()
	tween.tween_property(hud_control, "modulate:a", 1.0, 0.5)

func show_interact_prompt(text: String):
	if text == current_interact_text and interact_label.visible:
		return
	
	current_interact_text = text
	interact_label.text = text
	interact_label.visible = true
	
	var tween = create_tween()
	tween.tween_property(interact_label, "modulate:a", 1.0, 0.2)

func hide_interact_prompt():
	if not interact_label.visible:
		return
	
	current_interact_text = ""
	var tween = create_tween()
	tween.tween_property(interact_label, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func(): interact_label.visible = false)

func update_sos_count(count: int):
	sos_label.text = "Fragments SOS: " + str(count) + "/3"
	if count >= 3:
		sos_label.modulate = Color.GREEN

func show_beacon_held():
	beacon_held_label.visible = true
	beacon_held_label.text = "Balise SOS en main - Posez-la près du shelter"

func hide_beacon_held():
	beacon_held_label.visible = false

func fade_to_black():
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	$HUD_Control.add_child(fade)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 3.0)
