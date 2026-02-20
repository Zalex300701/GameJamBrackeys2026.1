extends Node3D

@onready var dialog_label = $DialogLabel
@onready var audio_player = $AudioStreamPlayer3D

var dialog_queue = []
var is_playing = false

func _ready():
	dialog_label.text = ""

func play_dialog(text: String, audio: AudioStream = null):
	dialog_queue.append({"text": text, "audio": audio})
	if not is_playing:
		_process_queue()

func _process_queue():
	if dialog_queue.is_empty():
		is_playing = false
		return
	
	is_playing = true
	var dialog = dialog_queue.pop_front()
	
	# Affiche le texte
	dialog_label.text = dialog.text

	# Joue l'audio si fourni
	if dialog.audio:
		audio_player.stream = dialog.audio
		audio_player.play()
		await audio_player.finished
	else:
		await get_tree().create_timer(3.0).timeout  # durée par défaut

	# Efface et passe au suivant
	dialog_label.text = ""
	await get_tree().create_timer(0.5).timeout
	_process_queue()
