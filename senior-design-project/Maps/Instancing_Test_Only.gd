extends Node2D

@onready var PreloadInstance : PackedScene = preload("res://Maps/Instances/Boss Instance.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#var inst = PreloadInstance.instantiate()
	#inst.global_position = $InstanceLocation.global_position
	#add_child(inst)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
