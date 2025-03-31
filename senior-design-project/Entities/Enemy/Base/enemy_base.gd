class_name EnemyBaseScene extends CharacterBody2D

@onready var PlayerRef : CharacterBaseScene = get_tree().get_first_node_in_group("Player")
@export var MaxHP: int = 10
@export var CurrentHP: int = 10
@onready var StunTimer : Timer = $StunTimer
@onready var PlayerAggroTimer : Timer = $PlayerAggroTimer
@onready var PlayerRaycast : RayCast2D = $"PlayerRaycast"

func _physics_process(delta): #Override this
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _AI(delta : float):#Override This
	pass

func TakeDamage(amount: int):
	CurrentHP -= amount
	print("Enemy took " + str(amount) + " damage")
	
	if CurrentHP <= 0:
		Die()

func _Got_Hit(Data : AttackData): #Override This
	print("i got hit")
	#$"Delete this - testing only".visible = true
	#$"Delete this - testing only/Timer".start()

func delete_this_testing_only():
	$"Delete this - testing only".visible = false

func Die():
	print("I Died")
	pass

func PlayerDetection(body: Node2D) -> void: #override this
	pass # Replace with function body.

func PlayerDetection_Leave(body: Node2D) -> void:
	pass # Replace with function body.

func _Despawn() -> void: #call this if too far from player and not in aggro
	pass
