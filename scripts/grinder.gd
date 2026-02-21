extends StaticBody3D

signal grind_finished
signal death_animation_triggered

@onready var grind_animation: AnimationPlayer = $GrindAnimation
@onready var treasure_spawnpoint: Marker3D = $TreasureSpawnpoint
@onready var death_anim = $GrinderDeathAnimation
@onready var anim_player = $GrinderDeathAnimation/ArmAnimation
@onready var grind: AudioStreamPlayer3D = $Grind

func _ready() -> void:
	death_anim.visible = false

func interact(player):
	player.grind_all()

func get_interact_text() -> String:
	return "[E] Grind findings"

func spawn_and_grind_treasure(treasure_data: TreasureData):
	if treasure_data.scene_3d:
		var treasure_mesh = treasure_data.scene_3d.instantiate()
		treasure_spawnpoint.add_child(treasure_mesh)
		treasure_mesh.position = Vector3.ZERO
		treasure_mesh.scale = Vector3(0.3, 0.3, 0.3)
		
		grind_animation.play("grind")
		grind.play()
		
		var tween = create_tween()
		tween.tween_property(treasure_mesh, "position", Vector3(0, -0.5, 0), 3.0)
		tween.tween_callback(treasure_mesh.queue_free)
		
		await get_tree().create_timer(grind_animation.current_animation_length).timeout
		grind_finished.emit()

func play_death_animation():
	if death_anim:
		death_anim.visible = true
		grind.play()
		anim_player.play("arm_grinded")
