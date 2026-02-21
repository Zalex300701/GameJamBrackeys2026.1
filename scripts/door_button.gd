extends StaticBody3D

@export var door: Node3D  # assigne la porte dans l'inspecteur

func interact(player):
	if door and door.has_method("toggle"):
		door.toggle()

func get_interact_text() -> String:
	if door and door.is_open:
		return "[E] Close the door"
	else:
		return "[E] Open the door"
