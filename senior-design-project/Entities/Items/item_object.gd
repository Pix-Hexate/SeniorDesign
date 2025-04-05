class_name Item_Object extends Node2D
var Data : Item_Data 
@onready var Icon : TextureRect = $TextureRect
@onready var Text : RichTextLabel = $Panel/RichTextLabel
@onready var Display : Panel = $Panel
@onready var PlayerRef : CharacterBaseScene = get_tree().get_first_node_in_group("Player")
var Taken : bool = false
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
	else:
		Data = Item_Data.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Display.visible:
		if Input.is_action_pressed("InteractKey"): 
			Take_Item()

func Take_Item():
	if not Taken:
		Taken = true
		PlayerRef.ApplyUpgrade(Data)
		queue_free()


func Player_Entered(body):
	if body.has_method("ApplyUpgrade"):  # Check if the character has the function
		body.ApplyUpgrade(Data)  # Give armor
		queue_free()  # Remove the item after pickup
	# Display.visible = true


func Player_Left(body):
	Display.visible = false
