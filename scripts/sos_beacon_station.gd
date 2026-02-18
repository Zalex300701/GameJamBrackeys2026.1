extends StaticBody3D

func interact(player):
	if player.sos_fragments >= 3:
		player.give_beacon()
	else:
		print("Il manque ", 3 - player.sos_fragments, " fragment(s)")

func get_interact_text() -> String:
	var player = get_tree().get_first_node_in_group("player")
	if player.sos_fragments >= 3:
		return "[E] Construire la balise SOS"
	else:
		return "Fragments SOS: " + str(player.sos_fragments) + "/3"
