extends Node2D
#This will play every sound in the game, each thing that needs to play a sound will send a signal to the audio manager
#Audio signals will bypass the signalbus


func _ready():
	pass

func Queue_Sound(sound : String):
	match sound:
		"ButtonHover":
			Play_Sound("ButtonHover") #THIS IS JUST HERE FOR TESTING, THIS IS NOT HOW IT WILL FUNCTION
		_:
			print("ERROR INCORRECT STRING IN AUDIOPLAYER, GOT " + sound)
	
	
func Play_Sound(sound:String): #THIS IS JUST HERE FOR TESTING, THIS IS NOT HOW IT WILL FUNCTION
	match sound:
		"ButtonHover":
			$"Temp Sounds/TESTING_DELETE THIS".play()
