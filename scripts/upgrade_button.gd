extends StaticBody3D

var upgrade_costs = [100, 1000]

@onready var level_label: Label3D = $LevelLabel
@onready var cost_label: Label3D = $CostLabel
var cost_original_color = Color.WHITE

var cost_flash_tween = null

func _ready():
	_update_display()

func interact(player):
	var detector = get_tree().get_first_node_in_group("detector")
	var current_level = detector.get_level()

	if current_level >= 3:
		return

	var cost = upgrade_costs[current_level - 1]

	if player.total_dollars >= cost:
		player.total_dollars -= cost
		player.hud.update_dollars(player.total_dollars)
		detector.upgrade()
		
		if current_level == 1:
			player.computer.play_dialog("Your detector is much more stronger now. You will find deeper specimens.", preload("res://assets/sounds/voices/Line6.ogg"))
		elif current_level == 2:
			player.computer.play_dialog("This is a massive upgrade. Beware, your next findings  may be unusual.", preload("res://assets/sounds/voices/Line7.ogg"))
		
		_update_display()
	
	else:
		_flash_cost_label()

func _flash_cost_label():
	if not cost_label:
		return

	# Tue et reset immédiatement
	if cost_flash_tween and cost_flash_tween.is_valid():
		cost_flash_tween.kill()

	# Force reset de la couleur avant de commencer
	cost_label.modulate = cost_original_color

	# Nouveau tween
	cost_flash_tween = create_tween()
	for i in range(3):  # 3 clignotements manuels
		cost_flash_tween.tween_property(cost_label, "modulate", Color.RED, 0.15)
		cost_flash_tween.tween_property(cost_label, "modulate", cost_original_color, 0.15)

func _update_display():
	var detector = get_tree().get_first_node_in_group("detector")
	if not detector:
		return
	var current_level = detector.get_level()

	if level_label:
		level_label.text = str(current_level)

	if cost_label:
		if current_level >= 3:
			cost_label.text = "MAX"
			cost_label.modulate = Color.RED
			cost_original_color = Color.RED  # ← met à jour la couleur stockée
		else:
			var cost = upgrade_costs[current_level - 1]
			cost_label.text = "$" + str(cost)
			cost_label.modulate = Color.WHITE
			cost_original_color = Color.WHITE  # ← met à jour la couleur stockée

func get_interact_text() -> String:
	return "[E] Upgrade Detector"
