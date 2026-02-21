extends StaticBody3D

var is_activated: bool = false

func interact(player):
	if not is_activated:
		_activate(player)

func _activate(player):
	is_activated = true
	print("Balise activée... Quelque chose approche...")
	_start_horror_sequence(player)

func _start_horror_sequence(player):
	# Désactive le joueur
	player.set_physics_process(false)
	player.can_pause = false
	player.is_dead = true
	player.detector.set_process(false)
		
	player.hud.fade_out(2.0)
	
	# Phase 1 : Balise démarre (5 secondes)
	# Ajoute une animation de lumière clignotante sur la balise
	var tween = create_tween()
	tween.set_loops(10)
	# Anime une lumière sur la balise si tu en as une
	
	await get_tree().create_timer(5.0).timeout
	
	# Phase 2 : Coupure électrique totale
	_power_outage(player)
	
	await get_tree().create_timer(3.0).timeout
	
	# Phase 3 : Spawn des ennemis (10 secondes)
	_spawn_enemies(player)
	
	await get_tree().create_timer(25.0).timeout
	
	# Phase 4 : Écran noir + crédits
	_end_credits(player)

func _power_outage(player):
	# Arrête la musique d'ambiance
	AudioManager.stop_ambient(2.0)
	
	# Éteint la lampe torche du joueur
	if player.has_node("Player_Head/Player_Camera3D/Torch"):
		var torch = player.get_node("Player_Head/Player_Camera3D/Torch")
		var tween = create_tween()
		tween.tween_property(torch, "light_energy", 0.0, 1.0)
	
	# Son de coupure électrique
	# AudioManager.play_sfx(preload("res://sounds/power_off.ogg"))

func _spawn_enemies(player):
	var ghost_scene = preload("res://scenes/ghost.tscn")
	var spawn_count = 20  # nombre de fantômes
	
	for i in range(spawn_count):
		var ghost = ghost_scene.instantiate()
		get_tree().current_scene.add_child(ghost)
		
		# Spawn en cercle autour du joueur
		var angle = (TAU / spawn_count) * i
		var distance = randf_range(15.0, 20.0)
		var offset = Vector3(cos(angle), 0, sin(angle)) * distance
		ghost.global_position = player.global_position + offset - Vector3(0, 1, 0)
		ghost.start_cinematic()
		
		# Délai progressif entre chaque spawn
		await get_tree().create_timer(0.7).timeout

func _end_credits(player):
	# Fade to black brutal
	player.hud.fade_to_black_instant()
	
	await get_tree().create_timer(2.0).timeout
	
	# Change vers la scène de crédits
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func get_interact_text() -> String:
	if is_activated:
		return ""
	return "[E] Activate SOS Beacon"
