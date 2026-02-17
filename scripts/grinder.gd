extends StaticBody3D

func interact(player):
	player.grind_all()

func get_interact_text() -> String:
	return "[E] Broyer les trésors"
