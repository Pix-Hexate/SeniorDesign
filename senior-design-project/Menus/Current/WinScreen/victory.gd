extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.WIN.connect(win)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func win():
	visible = true
	get_tree().paused = true

func _on_better_button_pressed():
	AudioManager.StartMenu()
	get_tree().paused = false
	print("RETURN PRESSED")
	get_tree().change_scene_to_file("res://Menus/Current/Main/MainMenu.tscn")
