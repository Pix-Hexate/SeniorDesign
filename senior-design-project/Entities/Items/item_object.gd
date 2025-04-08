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
		Text.text = Data.Name + "\n"
		match Data.Name:
			"Swiftness":
				Text.text = "Gain increased movement speed"
			"Vitality":
				Text.text = "Increase your maximum health by 40"
			"Protection Veil":
				Text.text = "Lower damage taken by 5"
			"Alacrity":
				Text.text = "Increase your striking speed"
			"Strength":
				Text.text = "Increase your strike damage"
			"Tome of Accuracy":
				Text.text = "Gain increased chance to critically strike"
			"Tome of Lethality":
				Text.text = "Critical strikes do significantly more damage"
			"Rejuvination":
				Text.text = "Regain health substantially quicker"
			"Star Veil":
				Text.text = "Every 15 seconds, gain a barrier which blocks one hit"
			"Hermes Boots":
				Text.text = "Gain a second jump in the air"
			"Readiness":
				Text.text = "When your abilities are off cooldown, you do more damage"
			"Torch":
				Text.text = "Apply burn to enemies on hit"
			"Vampiric Essence":
				Text.text = "Gain a portion of the damage you deal back as life"
			"Quickness":
				Text.text = "Your abilities regenerate quicker"
			_:
				Text.text = "UNKNOWN ITEM - " + str(Data.Name)
	else:
		Data = Item_Data.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Display.visible:
		if Input.is_action_pressed("InteractKey"): 
			Take_Item()

func Take_Item():
	if not Taken:
		print("Took Item - " + Data.Name)
		Taken = true
		PlayerRef.ApplyUpgrade(Data)
		queue_free()


func Player_Entered(body):
	Display.visible = true


func Player_Left(body):
	Display.visible = false
