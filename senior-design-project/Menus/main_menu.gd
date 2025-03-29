extends Control

@onready var options_menu = preload("res://Menus/options_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Maps/TestMap.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_option_button_pressed() -> void:
	var options_instance = options_menu.instantiate()
	options_instance.back_pressed.connect(_on_options_closed)  # Connect signal
	get_parent().add_child(options_instance)  # Add to the scene tree
	hide()

func _on_options_closed() -> void:
	show()  # Show main menu again
