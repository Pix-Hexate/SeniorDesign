extends Node
#Tracks Game statistics and stuff
var All_Items : Array[Item_Data] = []
var Temp_Item : Item_Data 
var filepath : String = "res://Resources/Test Items.json"

func _ready():
	Initalize_Items()

func Initalize_Items():
	if FileAccess.file_exists(filepath):
		var datafile = FileAccess.open(filepath, FileAccess.READ)
		var raw_data = JSON.parse_string(datafile.get_as_text()) #this should be an array of dicts, with each dict being one item
		
		for data in (raw_data as Array):
			if data is Dictionary: #0 is a "filler" to match up IDs with indices, so we ignore it
				Temp_Item = Item_Data.new()
				Temp_Item.Effects = data["Effects"] #effects is a dict
				Temp_Item.Name = str(data["Name"])
				Temp_Item.Icon = load("res://Resources/Upgrade Icons/" + str(data["Name"]) + ".png")
				All_Items.append(Temp_Item)		
		
