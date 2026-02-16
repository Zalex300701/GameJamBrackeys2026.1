extends Control

@onready var resume_btn: Button = $ColorRect/VBoxContainer/Resume_button
@onready var quit_btn: Button = $ColorRect/VBoxContainer/Quit_button

var is_open := false

func _ready() -> void:
	visible = false
	resume_btn.pressed.connect(_on_resume)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)

func toggle() -> void:
	is_open = !is_open
	visible = is_open

	get_tree().paused = is_open

	if is_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume() -> void:
	if is_open:
		toggle()

func _on_quit() -> void:
	get_tree().quit()
