extends StaticBody3D

var upgrade_costs = [100, 1000]

func interact(player):
	var detector = player.get_node("Detector")
	var current_level = detector.get_level()

	if current_level >= 3:
		print("Détecteur déjà au niveau maximum !")
		return

	var cost = upgrade_costs[current_level - 1]  # level 1 → index 0, level 2 → index 1

	if player.total_dollars >= cost:
		player.total_dollars -= cost
		player.hud.update_dollars(player.total_dollars)
		detector.upgrade()
		print("Détecteur upgradé au niveau ", detector.get_level(), " !")
	else:
		print("Pas assez d'argent ! Coût : $", cost)

func get_interact_text() -> String:
	var detector = get_tree().get_first_node_in_group("player").get_node("Detector")
	var current_level = detector.get_level()
	if current_level >= 3:
		return "Détecteur au niveau max"
	var cost = upgrade_costs[current_level - 1]
	return "[E] Améliorer détecteur ($" + str(cost) + ")"
