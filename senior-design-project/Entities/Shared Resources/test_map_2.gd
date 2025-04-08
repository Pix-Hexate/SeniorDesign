extends Node2D

var itemobject = preload("res://Entities/Items/Item_Object.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	AudioManager.StartLevel()
	GameManager.All_Items.shuffle()
	var counter :  int = 0
	for loc in $ItemLocations.get_children():
		var item : Item_Object = itemobject.instantiate()
		item.Data = GameManager.All_Items[counter]
		item.global_position = loc.global_position
		add_child(item)
		counter += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
