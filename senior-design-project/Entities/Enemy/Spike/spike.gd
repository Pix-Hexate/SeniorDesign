class_name Spike extends Node2D

@onready var _Hurtbox : Area2D = $Spike/Hurtbox
@export var Teleport_Location : Marker2D
@export var Damage : float = 15
@export var Enabled : bool = true
@export var Teleporter : bool = true
@onready var AnimPlayer : AnimationPlayer = $Spike/AnimationPlayer
var StoredAttackData : AttackData = null
# Called when the node enters the scene tree for the first time.

func _ready():
	StoredAttackData = AttackData.new()
	StoredAttackData.Damage = Damage
	if not Enabled:
		$Spike/Hurtbox/CollisionShape2D.disabled = true

func SpikeUP():
	$Spike.position = Vector2(0,0)
	AnimPlayer.play("SpikeUP")
	get_parent()

func _on_hurtbox_area_entered(area):
	if StoredAttackData.Damage == -1:
		print("THERE IS A HURTBOX WITH AN UNSET ATTACK VALUE")
	
	StoredAttackData.Source = global_position
	if area.get_parent() is CharacterBaseScene:
		area.Got_Hit(StoredAttackData)
		if Teleporter:
			if is_instance_valid(Teleport_Location):
				area.get_parent().global_position = Teleport_Location.global_position
