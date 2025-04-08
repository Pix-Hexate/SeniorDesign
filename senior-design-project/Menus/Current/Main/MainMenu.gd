extends Control

var MainButtons : Array
@onready var PlayButton : BetterButton = $Main/PlayButton
@onready var OptionsButton : BetterButton = $Main/OptionsButton
@onready var CreditsButton : BetterButton = $Main/CreditsButton
@onready var QuitButton : BetterButton = $Main/QuitButton

var OptionsButtons : Array 
@onready var ResolutionButton : OptionButton = $Options/HBoxContainer/ResolutionButton
@onready var FullscreenButton : BetterButton = $Options/FullScreen
@onready var OptionsBackButton : BetterButton = $Options/OptionsBack

@onready var VolumeBar : TextureProgressBar = $Options/Volume
@onready var VolumeText : Label = $Options/Volume/Label

@onready var FadePlayer1 : AnimationPlayer = $FadePlayer
@onready var FadePlayer2 : AnimationPlayer = $FadePlayer2
# Called when the node enters the scene tree for the first time.
func _ready():
	$"Fancy Animations/AnimationPlayer".play("Shifting")
	MainButtons = [PlayButton, OptionsButton, CreditsButton, QuitButton]
	OptionsButtons = [ResolutionButton, FullscreenButton, OptionsBackButton]




#region Main menu funcs
func PlayPressed():
	get_tree().change_scene_to_file("res://Entities/Shared Resources/TestMap2.tscn")
	
func OptionsPressed():
	for button in MainButtons:
		button.disabled = true
	FadePlayer1.play("MainFadeOut")
	await get_tree().create_timer(.5).timeout
	$Options.visible = true
	FadePlayer2.play("OptionFadeIn")
	await get_tree().create_timer(.5).timeout
	$Main.visible = false
	for button in OptionsButtons:
		button.disabled = false


func CreditsPressed():
	FadePlayer2.play("MainFadeOut")
	await get_tree().create_timer(.5).timeout
	$Credits.visible = true
	FadePlayer1.play("CreditsFadeIn")
	await get_tree().create_timer(.5).timeout
	$Main.visible = false



func QuitPressed():
	get_tree().quit()
#endregion

#region Option menu funcs

func VolumeChanged(val : float):
	VolumeBar.value = val
	VolumeText.text = "Volume - " + str(val)
	AudioManager.MasterVolumePercent = val

func ResolutionChanged(index : int):
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(640, 360))
		1:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		2:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		3:
			DisplayServer.window_set_size(Vector2i(2560, 1440))

var FullScreenOn : bool = false
func FullscreenPressed():
	if FullScreenOn:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		FullScreenOn = false
		ResolutionButton.disabled = false
		FullscreenButton.text = "Fullscreen - off"
		FullscreenButton.TextChanged()
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		FullScreenOn = true
		ResolutionButton.disabled = true
		FullscreenButton.text = "Fullscreen - on"
		FullscreenButton.TextChanged()
		
func OptionsBackPressed():
	for button in OptionsButtons:
		button.disabled = true
	FadePlayer1.play("OptionFadeOut")
	await get_tree().create_timer(.5).timeout
	$Main.visible = true
	FadePlayer2.play("MainFadeIn")
	await get_tree().create_timer(.5).timeout
	$Options.visible = false
	for button in MainButtons:
		button.disabled = false


#endregion


func CreditsBackPressed() -> void:
	FadePlayer1.play("CreditsFadeOut")
	await get_tree().create_timer(.5).timeout
	$Main.visible = true
	FadePlayer2.play("MainFadeIn")
	await get_tree().create_timer(.5).timeout
	$Credits.visible = false
