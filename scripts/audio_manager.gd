extends Node

# Musique d'ambiance
var ambient_music: AudioStreamPlayer
var is_ambient_playing: bool = false

# SFX pools
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 10

func _ready():
	# Crée le player de musique d'ambiance
	ambient_music = AudioStreamPlayer.new()
	ambient_music.bus = "Music"  # crée ce bus dans l'Audio Bus Layout
	add_child(ambient_music)

	# Crée un pool de joueurs SFX
	for i in MAX_SFX_PLAYERS:
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

func play_ambient(stream: AudioStream):
	if is_ambient_playing:
		return
	ambient_music.stream = stream
	ambient_music.play()
	is_ambient_playing = true

func stop_ambient(fade_duration: float = 2.0):
	if not is_ambient_playing:
		return
	var tween = create_tween()
	tween.tween_property(ambient_music, "volume_db", -80, fade_duration)
	tween.tween_callback(func():
		ambient_music.stop()
		ambient_music.volume_db = 0
		is_ambient_playing = false
	)

func play_sfx(stream: AudioStream, volume_db: float = 0.0):
	# Trouve un player libre
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return
	# Si tous sont occupés, force le premier
	sfx_players[0].stream = stream
	sfx_players[0].volume_db = volume_db
	sfx_players[0].play()

func play_sfx_3d(stream: AudioStream, position: Vector3, volume_db: float = 0.0):
	# Pour les sons positionnels (à implémenter si besoin)
	pass
