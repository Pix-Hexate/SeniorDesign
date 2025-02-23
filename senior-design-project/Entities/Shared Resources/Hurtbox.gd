class_name Hurtbox extends Area2D

var StoredAttackData : AttackData = null

func _on_area_entered(area):
	if area is Hitbox:
		area.Got_Hit(StoredAttackData)
