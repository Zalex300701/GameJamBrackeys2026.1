extends CanvasLayer

@onready var oxygen_bar = $HUD_Control/OxygenBar
@onready var inventory_list: VBoxContainer = $HUD_Control/InventoryList

func update_oxygen(value: float):
	oxygen_bar.value = value

func add_to_list(item : HBoxContainer):
	inventory_list.add_child(item)
