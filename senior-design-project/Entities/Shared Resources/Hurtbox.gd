class_name Hurtbox extends Area2D

var StoredAttackData : AttackData = null

func _ready():
	StoredAttackData = AttackData.new()
	StoredAttackData.Damage = -1

func _on_area_entered(area):
	if StoredAttackData.Damage == -1:
		print("THERE IS A HURTBOX WITH AN UNSET ATTACK VALUE")
	
	StoredAttackData.Source = global_position
	area.Got_Hit(StoredAttackData)
