extends Node

@onready var play_btn = $CanvasLayer/MenuUI/VBoxContainer/PlayButton
@onready var options_btn = $CanvasLayer/MenuUI/VBoxContainer/OptionsButton
@onready var quit_btn = $CanvasLayer/MenuUI/VBoxContainer/QuitButton

func _ready():
	# Lance la musique d'ambiance
	AudioManager.play_ambient(preload("res://assets/sounds/ambience_alien_planet.ogg"))

	# Connecte les boutons
	play_btn.pressed.connect(_on_play)
	if options_btn:
		options_btn.pressed.connect(_on_options)
	quit_btn.pressed.connect(_on_quit)

	# Rend la souris visible
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_play():
	# SFX de clic (si tu as le son)
	# AudioManager.play_sfx(preload("res://sounds/button_click.ogg"))

	# Fade to black optionnel
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	$CanvasLayer.add_child(fade)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)

	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.5)
	await tween.finished

	get_tree().change_scene_to_file("res://scenes/game_test.tscn")

func _on_options():
	print("Options pas encore implémentées")

func _on_quit():
	# AudioManager.play_sfx(preload("res://sounds/button_click.ogg"))
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
