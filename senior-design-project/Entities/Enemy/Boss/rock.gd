extends RigidBody2D

@onready var _Hurtbox : Hurtbox = $Hurtbox
var rand_rot : float = randf_range(150,800)
@onready var Sprite : Sprite2D = $Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready():
	
	var AtkData : AttackData = AttackData.new()
	AtkData.Damage = 25
	_Hurtbox.StoredAttackData = AtkData
	if randf() > .5:
		rand_rot *= -1

func _physics_process(delta):
	Sprite.rotation_degrees += delta*rand_rot
	if freeze:
		position.y += delta*15

func _on_lifespan_timeout():
	queue_free()


func _on_ready_timer_timeout():
	freeze = false
