extends StaticBody3D

var is_activated: bool = false

func interact(player):
	if not is_activated:
		_activate()

func _activate():
	is_activated = true
	print("Balise activée... Quelque chose approche...")
	_start_horror_sequence()

func _start_horror_sequence():
	# Désactive le contrôle du joueur
	var player = get_tree().get_first_node_in_group("player")
	player.set_physics_process(false)
	
	# Effets horrifiques
	await get_tree().create_timer(2.0).timeout
	# Ajoute tes lumières qui clignotent, sons, etc.
	
	await get_tree().create_timer(5.0).timeout
	_end_game()

func _end_game():
	var player = get_tree().get_first_node_in_group("player")
	player.hud.fade_to_black()
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/end_credits.tscn")

func get_interact_text() -> String:
	if is_activated:
		return ""
	return "[E] Activer la balise SOS"
