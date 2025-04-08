class_name Spike_Area extends Area2D

@export var Teleport_Location : Marker2D
@export var Damage : float = 15
@export var Enabled : bool = true
@export var Teleporter : bool = true
var StoredAttackData : AttackData = null
# Called when the node enters the scene tree for the first time.

func _ready():
	StoredAttackData = AttackData.new()
	StoredAttackData.Damage = Damage
	if not Enabled:
		$Spike/Hurtbox/CollisionShape2D.disabled = true


func _on_body_entered(area):
	print("seeing something enter")
	if StoredAttackData.Damage == -1:
		print("THERE IS A SPIKE WITH AN UNSET ATTACK VALUE")
	
	StoredAttackData.Source = global_position
	if area is CharacterBaseScene:
		area._Got_Hit(StoredAttackData)
		if Teleporter:
			if is_instance_valid(Teleport_Location):
				area.global_position = Teleport_Location.global_position
