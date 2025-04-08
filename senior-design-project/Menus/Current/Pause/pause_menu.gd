extends Control

var OptionsButtons : Array 
@onready var ResolutionButton : OptionButton = $Options/HBoxContainer/ResolutionButton
@onready var FullscreenButton : BetterButton = $Options/FullScreen
@onready var OptionsBackButton : BetterButton = $Options/OptionsBack

@onready var VolumeBar : TextureProgressBar = $Options/Volume
@onready var VolumeText : Label = $Options/Volume/Label

@onready var FadePlayer1 : AnimationPlayer = $FadePlayer
@onready var FadePlayer2 : AnimationPlayer = $FadePlayer2


var MainButtons : Array
@onready var ResumeButton : BetterButton = $Main/ResumeButton
@onready var OptionsButton : BetterButton = $Main/OptionsButton
@onready var HomeButton : BetterButton = $Main/HomeButton
@onready var QuitButton : BetterButton = $Main/QuitButton

# Called when the node enters the scene tree for the first time.
func _ready():
	MainButtons = [ResumeButton, OptionsButton, HomeButton, QuitButton]
	OptionsButtons = [ResolutionButton, FullscreenButton, OptionsBackButton]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not get_tree().paused:
		if Input.is_action_pressed("ESC"):
			get_tree().paused = true
			visible = true

#region main funcs
func ResumePressed():
	visible = false
	get_tree().paused = false

func OptionsPressed():
	for button in MainButtons:
		button.disabled = true
	FadePlayer1.play("MainFadeOut")
	await get_tree().create_timer(.5).timeout
	FadePlayer2.play("OptionsFadeIn")
	await get_tree().create_timer(.5).timeout
	for button in OptionsButtons:
		button.disabled = false

func HomePressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menus/Current/Main/MainMenu.tscn")

func QuitPressed():
	get_tree().quit()

#endregion

#region options funcs
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
	FadePlayer2.play("OptionsFadeOut")
	await get_tree().create_timer(.5).timeout
	FadePlayer1.play("MainFadeIn")
	await get_tree().create_timer(.5).timeout
	for button in MainButtons:
		button.disabled = false
#endregion
