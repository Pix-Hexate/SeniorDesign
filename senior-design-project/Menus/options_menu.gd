extends Control

signal back_pressed  # Define a signal

@onready var resolution_button : OptionButton = $MarginContainer/HBoxContainer/ContainerGraphics/ResolutionButton # Reference to OptionButton (Resolution)
@onready var settings_manager = preload("res://SettingsManager.gd")  # Preload SettingsManager script

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	if resolution_button:
		# Add resolution options to the ResolutionButton as integers
		resolution_button.add_item("640x360")  # Option 1 (index 0)
		resolution_button.add_item("1280x720")  # Option 2 (index 1)
		resolution_button.add_item("1920x1080")  # Option 3 (index 2)
	
		# Connect the signal properly to a function
		resolution_button.connect("item_selected",  Callable(self, "_on_resolution_selected"))
	
		# Instantiate the SettingsManager
		settings_manager = settings_manager.new()  # Instantiate the SettingsManager script
	else:
		print("Error: ResolutionButton Not Found")

# This function will be called when a resolution is selected from the OptionButton
func _on_resolution_selected(index: int) -> void:
	match index:
		0:
			settings_manager.Resolution = 1  # 640x360
		1:
			settings_manager.Resolution = 2  # 1280x720
		2:
			settings_manager.Resolution = 3  # 1920x1080
		_:
			settings_manager.Resolution = 3  # Default to 1920x1080

	settings_manager.AdjustResolution()  # Apply the new resolution

func _on_back_button_pressed() -> void:
	back_pressed.emit()  # Notify the main menu
	queue_free()  # Remove the options menu from the scene tree
