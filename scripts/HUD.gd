extends CanvasLayer

@onready var hud_control = $HUD_Control
@onready var oxygen_bar = $HUD_Control/OxygenBar
@onready var inventory_list: VBoxContainer = $HUD_Control/InventoryList
@onready var dollars_label = $HUD_Control/DollarsLabel
@onready var death_screen = $Death_Control/DeathScreen
@onready var death_label = $Death_Control/DeathLabel

var hud_items = {}

signal death_fade_finished

func _ready():
	death_screen.visible = false
	death_label.modulate.a = 0.0

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
