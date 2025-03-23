class_name Knight extends CharacterBaseScene


func Process_Action_Inputs():
	match Buffered_Keys["Action"]:
		"AbilityOne":
			if not Playing_Action:
				AnimPlayer.play("AbilityOne")
				Buffered_Keys["Action"] = ""
		"AbilityTwo":
			if not Playing_Action:
				AnimPlayer.play("AbilityTwo")
				Buffered_Keys["Action"] = ""
		"AbilityThree":
			pass
		"AbilityFour":
			TEMPORARY_TEST_FUNC()
			Buffered_Keys["Action"] = ""
