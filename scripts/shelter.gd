extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.enter_shelter()
		_kill_ghost()

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.leave_shelter()

func _kill_ghost():
	var ghost = get_tree().get_first_node_in_group("ghost")
	if ghost:
		ghost.stop_chase()
