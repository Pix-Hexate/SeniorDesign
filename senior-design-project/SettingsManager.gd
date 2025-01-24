extends Node

# Variable to store the selected resolution setting
var Resolution: int = 3  # Default to 1920x1080

# Variable to store fullscreen state
var Fullscreen: bool = false

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# You can load settings from a file or save system if you want persistent settings
	pass

# Adjusts the resolution based on the selected value
func AdjustResolution() -> void:
	match Resolution:
		1:
			DisplayServer.window_set_size(Vector2i(640, 360))  # 640x360
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))  # 1280x720
		3:
			DisplayServer.window_set_size(Vector2i(1920, 1080))  # 1920x1080
		4:
			DisplayServer.window_set_size(Vector2i(2560, 1440))  # 2560x1440
		_:
			DisplayServer.window_set_size(Vector2i(1920, 1080))  # Default resolution

# Toggles fullscreen mode on or off
func OptionFullscreen() -> void:
	if Fullscreen:
		Fullscreen = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		Fullscreen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
