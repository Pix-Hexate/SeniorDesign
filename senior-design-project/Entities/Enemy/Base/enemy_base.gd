class_name EnemyBaseScene extends CharacterBody2D

@onready var PlayerRef : CharacterBaseScene = get_tree().get_first_node_in_group("Player")
@export var MaxHP: int = 10
@export var CurrentHP: int = 10
@export var BurnDamage: int = 0
@export var PoisonDamage: int = 0
@onready var StunTimer : Timer = $StunTimer
@onready var TickDamageTimer: float = 0.0 # Used for calculating tick damage every second
@onready var PlayerAggroTimer : Timer = $PlayerAggroTimer
@onready var PlayerRaycast : RayCast2D = $"PlayerRaycast"


func _physics_process(delta): #Override this
	if not is_on_floor():
		velocity += get_gravity() * delta
	TickDamageTimer += delta
	if TickDamageTimer >= 1.0:  # Apply tick damage every second
		TickDamageTimer = 0
		ApplyTickDamage()
	move_and_slide()


func _AI(delta : float):#Override This
	pass

func TakeDamage(amount: int):
	CurrentHP -= amount
	print("Enemy took " + str(amount) + " damage")
	
	if CurrentHP <= 0:
		Die()

func ApplyTickDamage():
	if BurnDamage > 0:
		CurrentHP -= BurnDamage
		print("Enemy took " + str(BurnDamage) + "burn damage")
		BurnDamage -= 2
	if PoisonDamage > 0:
		CurrentHP -= PoisonDamage
		print("Enemy took " + str(PoisonDamage) + "poison damage")
		PoisonDamage -= 1
	
func ApplySpecialEffects(SpecialEffects : Dictionary):
	if SpecialEffects.has("BurnDamage"):
		BurnDamage += SpecialEffects["BurnDamage"]
	if SpecialEffects.has("PoisonDamage"):
		PoisonDamage += SpecialEffects["PoisonDamage"]	

func _Got_Hit(Data : AttackData): #Override This
	print("i got hit -- enemy base -- OVERRIDE THIS")
	#$"Delete this - testing only".visible = true
	#$"Delete this - testing only/Timer".start()

func Die():
	print("I Died")
	pass

func PlayerDetection(body: Node2D) -> void: #override this
	pass # Replace with function body.

func PlayerDetection_Leave(body: Node2D) -> void:
	pass # Replace with function body.

func _Despawn() -> void: #call this if too far from player and not in aggro
	pass
