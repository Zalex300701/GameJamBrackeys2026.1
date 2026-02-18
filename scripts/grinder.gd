extends StaticBody3D

signal death_animation_triggered

@onready var death_anim = $GrinderDeathAnimation
@onready var anim_player = $GrinderDeathAnimation/ArmAnimation

func _ready() -> void:
	death_anim.visible = false

func interact(player):
	player.grind_all()

func get_interact_text() -> String:
	return "[E] Broyer les trésors"

func play_death_animation():
	if death_anim:
		death_anim.visible = true
		anim_player.play("arm_grinded")
