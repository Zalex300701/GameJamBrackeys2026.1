extends CanvasLayer

@onready var oxygen_bar = $HUD_Control/OxygenBar
@onready var inventory_list: VBoxContainer = $HUD_Control/InventoryList
@onready var dollars_label = $HUD_Control/DollarsLabel

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
