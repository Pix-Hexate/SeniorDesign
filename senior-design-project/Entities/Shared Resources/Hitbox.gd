class_name Hitbox extends Area2D


func Got_Hit(Data : AttackData):
	get_parent()._Got_Hit(Data)
	if not(get_parent()	is CharacterBaseScene):
		AudioManager.QueueRandomizedSound("HitSound")
