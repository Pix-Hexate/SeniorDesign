extends Node2D
#This will play every sound in the game, each thing that needs to play a sound will send a signal to the audio manager
#Audio signals will bypass the signalbus

var MasterVolumePercent : float = 15: #The settings menu will manually change these vars, and then call setvolume
	set(value):
		MasterVolumePercent = value
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(MasterVolumePercent/100))
var SFXVolumePercent : float = 100
var MusicVolumePercent : float = 50
@onready var MusicPlayer : AudioStreamPlayer2D = $Music
var Player_Pool : Array[AudioStreamPlayer] = [] 
const MAX_PLAYERS = 30
var SoundDict : Dictionary = {}
var BaseString : String = "res://Resources/Sounds/"

func _ready():
	for i in MAX_PLAYERS:
		var player : AudioStreamPlayer = AudioStreamPlayer.new()
		player.finished.connect(DonePlaying.bind(player))
		add_child(player)
		Player_Pool.append(player)

func PlaySound(stream : AudioStream):
	for player in Player_Pool:
		if !player.playing:
			player.stream = stream
			player.play()
			return

func QueueRandomizedSound(input : String):
	if input in SoundDict:
		PlaySound(SoundDict[input])
	else:
		var path : String = BaseString + input + ".wav"
		var stream := AudioStreamRandomizer.new()
		stream.random_pitch = 1.15
		stream.random_volume_offset_db = 1.5
		stream.add_stream(0,load(path))
		SoundDict[input] = stream
		PlaySound(SoundDict[input])
	

func QueueStableSound(input: String):
	if input in SoundDict:
		PlaySound(SoundDict[input])
	else:
		var path : String = BaseString + input + ".wav"
		var stream := AudioStream.new()
		stream.add_stream(0,load(path))
		SoundDict[input] = stream
		PlaySound(SoundDict[input])


func DonePlaying(player : AudioStreamPlayer):
	player.stop()
	
func StartLevel():
	$"Permanent Sounds/BGM".stream = load("res://Resources/Sounds/Game BGM.wav")
	$"Permanent Sounds/BGM".play()

func StartMenu():
	$"Permanent Sounds/BGM".stream = load("res://Resources/Sounds/Menu BGM.wav")
	$"Permanent Sounds/BGM".play()
