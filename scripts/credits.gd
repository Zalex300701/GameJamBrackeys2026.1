extends Control

@onready var thank_you_label = $ThankYouLabel
@onready var credits_label = $CreditsLabel
@onready var thanks_label: Label = $ThanksLabel

func _ready():
	# Cache les crédits et le bouton au départ
	thank_you_label.visible = false
	credits_label.visible = false
	thanks_label.visible = false

	# Séquence d'animation
	_start_credits_sequence()

func _start_credits_sequence():
	# Kill sound
	await get_tree().create_timer(3.0).timeout
	
	_fade_in(thank_you_label)
	await get_tree().create_timer(3.0).timeout
	_fade_out(thank_you_label)
	
	await get_tree().create_timer(2.0).timeout
	
	_fade_in(credits_label)
	await get_tree().create_timer(5.0).timeout
	_fade_out(credits_label)
	
	await get_tree().create_timer(2.0).timeout
	
	_fade_in(thanks_label)
	await get_tree().create_timer(4.0).timeout
	_fade_out(thanks_label)
	
	await get_tree().create_timer(2.0).timeout
	
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _fade_in(label: Label):
	label.visible = true
	label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 3.0)
	await tween.finished

func _fade_out(label: Label):
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 2.0)
	await tween.finished
	label.visible = false
