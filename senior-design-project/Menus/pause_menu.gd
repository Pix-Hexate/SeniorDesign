extends Node2D

@onready var options_menu = preload("res://Menus/options_menu.tscn")
@onready var pause_menu = $"."
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initial setup (can add other necessary setup here)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):  # If "pause" action is triggered
		pauseMenu()  # Toggle pause menu visibility

# Function to handle pausing and unpausing the game
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1  # Unpause the game
	else:
		pause_menu.show()
		Engine.time_scale = 0  # Pause the game

	paused = !paused  # Toggle the paused state

# Called when Settings button is pressed
func _on_settings_pressed() -> void:
	# Instantiate the options menu
	var options_instance = options_menu.instantiate()
	
	# Connect the back button to return to the game
	options_instance.back_pressed.connect(_on_options_closed)
	
	# Add the options menu to the current scene
	get_parent().add_child(options_instance)
	
	# Hide the pause menu while the options menu is open
	hide()

	# Pause the game while in the options menu
	Engine.time_scale = 0  # Pause the game when settings are open

# Called when the Options menu is closed (back button is pressed)
func _on_options_closed() -> void:
	# Resume the game when coming back from the options menu
	Engine.time_scale = 1
	
	# Hide the options menu and show the pause menu
	get_parent().get_node("OptionsMenu").queue_free()  # Remove the options menu from the scene
	show()  # Show the pause menu again
