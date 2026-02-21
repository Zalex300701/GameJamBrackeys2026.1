extends Area3D

@export var door: Node3D

var player_in_area: bool = false
var current_player = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta):
	# Vérifie en continu si le joueur peut régénérer
	if player_in_area and current_player:
		if door and not door.is_open:
			# Porte fermée = régénération active
			if not current_player.in_shelter:
				current_player.enter_shelter()
		else:
		# Porte ouverte = pas de régénération
			if current_player.in_shelter:
				current_player.leave_shelter()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		current_player = body
		_kill_ghost()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		if current_player:
			current_player.leave_shelter()
		current_player = null

func _kill_ghost():
	var ghost = get_tree().get_first_node_in_group("ghost")
	if ghost:
		ghost.stop_chase()
