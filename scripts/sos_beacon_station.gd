extends StaticBody3D

func interact(player):
	if player.sos_fragments >= 3:
		player.computer.play_dialog("Make sure to grind all your items.", preload("res://assets/sounds/voices/Line8.ogg"))
		player.give_beacon()

func get_interact_text() -> String:
	var player = get_tree().get_first_node_in_group("player")
	if player.sos_fragments >= 3:
		return "[E] Build SOS Beacon"
	else:
		return "SOS Beacon Fragments: " + str(player.sos_fragments) + "/3"
