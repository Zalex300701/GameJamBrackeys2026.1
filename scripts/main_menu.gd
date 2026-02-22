extends Node

@onready var play_btn = $CanvasLayer/MenuUI/VBoxContainer/PlayButton
@onready var options_btn = $CanvasLayer/MenuUI/VBoxContainer/OptionsButton
@onready var quit_btn = $CanvasLayer/MenuUI/VBoxContainer/QuitButton
@onready var fade: ColorRect = $CanvasLayer/MenuUI/Fade

@onready var menu_ui: Control = $CanvasLayer/MenuUI
@onready var options_panel: Control = $CanvasLayer/OptionsPanel
@onready var sound_slider: HSlider = $CanvasLayer/OptionsPanel/VBoxContainer/SoundSlider
@onready var fullscreen_check: CheckBox = $CanvasLayer/OptionsPanel/VBoxContainer/FullscreenCheck
@onready var back_btn: Button = $CanvasLayer/OptionsPanel/VBoxContainer/BackButton

func _ready():
	fade.modulate.a = 0.0
	
	# Lance la musique d'ambiance
	AudioManager.play_ambient(preload("res://assets/sounds/ambience_alien_planet.ogg"))
	
	options_panel.visible = false
	
	play_btn.pressed.connect(_on_play)
	options_btn.pressed.connect(_on_options)
	quit_btn.pressed.connect(_on_quit)
	
	# Options
	sound_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0)) * 100  # Bus 0 = Master
	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	
	sound_slider.value_changed.connect(_on_master_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	back_btn.pressed.connect(_on_back_from_options)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_play():
	# SFX de clic (si tu as le son)
	# AudioManager.play_sfx(preload("res://sounds/button_click.ogg"))

	# Fade to black optionnel
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.5)
	await tween.finished

	get_tree().change_scene_to_file("res://scenes/game_test.tscn")

func _on_back_from_options():
	options_panel.visible = false
	menu_ui.visible = true

func _on_options():
	menu_ui.visible = false
	options_panel.visible = true

func _on_master_changed(value: float):
	AudioServer.set_bus_volume_db(0, linear_to_db(value / 100.0))
	
func _on_fullscreen_toggled(pressed: bool):
	print("Fullscreen toggled: ", pressed)
	if pressed:
		print("Setting fullscreen")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		print("Setting windowed")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_quit():
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
