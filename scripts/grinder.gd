extends StaticBody3D

signal grind_finished
signal death_animation_triggered

@onready var grind_animation: AnimationPlayer = $GrindAnimation
@onready var treasure_spawnpoint: Marker3D = $TreasureSpawnpoint
@onready var death_anim = $GrinderDeathAnimation
@onready var anim_player = $GrinderDeathAnimation/ArmAnimation

func _ready() -> void:
	death_anim.visible = false

func interact(player):
	player.grind_all()

func get_interact_text() -> String:
	return "[E] Broyer les trésors"

func spawn_and_grind_treasure(treasure_data: TreasureData):
	if treasure_data.scene_3d:
		var treasure_mesh = treasure_data.scene_3d.instantiate()
		treasure_spawnpoint.add_child(treasure_mesh)
		treasure_mesh.position = Vector3.ZERO
		treasure_mesh.scale = Vector3(0.3, 0.3, 0.3)

		
		grind_animation.play("grind")
		
		var tween = create_tween()
		tween.tween_property(treasure_mesh, "position", Vector3(0, -0.5, 0), 1.8)
		tween.tween_callback(treasure_mesh.queue_free)
		
		await anim_player.animation_finished
		grind_finished.emit()

func play_death_animation():
	if death_anim:
		death_anim.visible = true
		anim_player.play("arm_grinded")
