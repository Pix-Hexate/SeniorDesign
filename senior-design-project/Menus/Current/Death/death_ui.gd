extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_return_pressed():
	AudioManager.StartMenu()
	print("RETURN PRESSED")
	get_tree().change_scene_to_file("res://Menus/Current/Main/MainMenu.tscn")



func _on_revive_pressed():
	var PlayerRef : CharacterBaseScene = get_tree().get_first_node_in_group("Player")
	PlayerRef.CurrentHP = PlayerRef.MaxHP
	visible = false
	get_tree().paused = false
