extends Node2D

var obj = preload("res://Entities/Items/Item_Object.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	var counter = 0
	for item in GameManager.All_Items:
		var instance = obj.instantiate()
		(instance as Item_Object).Data = item
		(instance as Item_Object).global_position = $Marker2D.global_position + Vector2(200,0)*counter
		counter += 1 
		add_child(instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
