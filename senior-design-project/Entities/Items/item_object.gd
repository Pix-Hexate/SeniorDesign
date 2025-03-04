class_name Item_Object extends Node2D
var Data : Item_Data
@onready var Icon : TextureRect = $TextureRect
@onready var Text : RichTextLabel = $Panel/RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	if is_instance_valid(Data):
		if is_instance_valid(Data.Icon):
			Icon.texture = Data.Icon
		Text.text = ""
		for key in Data.Effects:
			Text.text += key
			Text.text += " : "
			Text.text += str(Data.Effects[key]) #TODO NEED A SPECIAL EFFECTS READER
			Text.text += "\n"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func Player_Enter(area):
	if area.get_parent() is CharacterBaseScene:
		$Panel.visible = true

func Player_Leave(area):
	if area.get_parent() is CharacterBaseScene:
		$Panel.visible = false
