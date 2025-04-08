class_name MoleProjectile extends Area2D

@export var Damage : float = 15
@export var Normalized_Direction = Vector2(0,0)
@export var Velocity = 200


func _physics_process(delta):
	global_position += Normalized_Direction * Velocity * delta
	
func PlayerEntered(area):
	if area is Hitbox:
		var atkdata = AttackData.new()
		atkdata.Damage = Damage
		atkdata.Source = global_position
		area.Got_Hit(atkdata)
		#TODO particle effects here
		queue_free()


func _on_lifespan_timeout():
	queue_free()


func WallCollision(body):
	queue_free()
