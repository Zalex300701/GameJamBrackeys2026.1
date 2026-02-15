extends CanvasLayer

@onready var oxygen_bar = $HUD_Control/OxygenBar
@onready var dig_bar = $HUD_Control/DigBar

func update_oxygen(value: float):
	oxygen_bar.value = value
	dig_bar.visible = false

func show_dig_progress(value: float):
	dig_bar.visible = value > 0.0 and value < 1.0
	dig_bar.value = value * 100.0
