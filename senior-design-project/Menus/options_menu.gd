extends Node2D

signal back_pressed  # Define a signal

@onready var resolution_button : OptionButton = $CanvasLayer/Control/HBoxContainer2/ResolutionContainer/OptionButton # Reference to OptionButton (Resolution)
@onready var settings_manager = get_node("/root/SettingsManager")  # Ensure it references the existing node

@onready var music_volume: Label = %MusicVolume
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_volume: Label = %SfxVolume
@onready var sfx_slider: HSlider = %SfxSlider

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	if resolution_button:
		# Add resolution options to the ResolutionButton as integers
		resolution_button.add_item("640x360")  # Option 1 (index 0)
		resolution_button.add_item("1280x720")  # Option 2 (index 1)
		resolution_button.add_item("1920x1080")  # Option 3 (index 2)
	
		# Connect the signal properly to a function
		resolution_button.connect("item_selected",  Callable(self, "_on_resolution_selected"))
	else:
		print("Error: ResolutionButton Not Found")
		
	
	music_volume.text = "Music Volume: " + str(settings_manager.music_volume)
	sfx_volume.text = "SFX Volume: " + str(settings_manager.sfx_volume)

	music_slider.value = settings_manager.music_volume
	sfx_slider.value = settings_manager.sfx_volume

# Music/Volume
func _on_music_slider_drag_ended(value_changed: bool) -> void:
	music_slider.release_focus()

func _on_music_slider_value_changed(value: float) -> void:
	settings_manager.music_volume = value
	music_volume.text = "Music Volume: %d" % value  # Ensure text updates
	# AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100))

func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	sfx_slider.release_focus()

func _on_sfx_slider_value_changed(value: float) -> void:
	settings_manager.sfx_volume = value
	sfx_volume.text = "SFX Volume: " + str(settings_manager.sfx_volume)
	# AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),linear_to_db(settings_manager.sfx_volume/100))

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
