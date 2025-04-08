extends EnemyBaseScene

var AI_Timer : float = 0
var AI_PrevAttackSpecial : bool = true 
var AI_NextSpecial : int = 2 #2, 3, or 4
var AI_Phase : int = 0:
	get:
		return AI_Phase
	set(value):
		AI_Phase = value
		AI_Timer = 0
var Want_Right : bool = true #Which way the enemy "wants" to go, and determines the way its facing
var IsFacingRight : bool = true
var Acceleration : float = 330 #takes slightly under 1s to get to max speed
var Max_Speed : float = 300 #Player is 250 for reference
@onready var _Hurtbox : Hurtbox = $Hurtbox
@export var Damage : float = 20
@onready var BeamPlayer : AnimationPlayer = $BeamPlayer
@onready var AnimPlayer : AnimationPlayer = $AnimationPlayer

'''
AI 

The boss attempts to cycle through its 4 attacks in a 1-2-1-3-1-4 pattern, with some delays in between each attack

0 - Walking towards player x ("delay") (walking animation)
1 - Run to player and Swing sword. but only if the player is on the ground level (swing animation), if not, skip to next
2 - Laser beams across two levels of elevation (there are 3 in total) (spellcast animation)
3 - Stomp the ground, spawn rocks from above, in some time, they fall (stomp animation)
4 - Stomp the ground, spikes appear on certain areas of the ground, after some time, they pierce up (stomp animation)


The AI only has two active phases, 0 and 1
0 is "active waiting" phase and contributes time to next attack
1 is "inactive" phase, which means it's doing some sort of attack animation and waiting for it to finish
'''
func _ready():
	var atkdata : AttackData = AttackData.new()
	atkdata.Damage = Damage
	_Hurtbox.StoredAttackData = atkdata
	
	
func Activate():
	AI_Phase = 3
	AnimPlayer.play("Activate")
	await AnimPlayer.animation_finished
	AI_Phase = 0	

var IdleTime : float = 1.5
@onready var Sprite : AnimatedSprite2D = $Sprite2D
func _AI(delta : float):#Override This
	match AI_Phase:
		1:
			velocity.x = 0
		0:
			AI_Timer += delta
			if abs(PlayerRef.global_position.x - global_position.x) > 50:
				AnimPlayer.play("Walking")
				if (PlayerRef.global_position.x - global_position.x) > 0:
					Want_Right = true
					Sprite.flip_h = true
					velocity.x += delta * Acceleration
					
				else:
					Want_Right = false
					Sprite.flip_h = false
					velocity.x -= delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
			else:
				AnimPlayer.play("Idle")
				velocity.x *= .85
					
			
			if AI_Timer >= IdleTime:
				AI_Phase = 1
				match AI_PrevAttackSpecial:
					true:
						Swing()
						AI_PrevAttackSpecial = false
					false:
						AI_PrevAttackSpecial = true
						match AI_NextSpecial:
							2:
								LaserCast()
								AI_NextSpecial = 3
							3:
								Rockfall()
								AI_NextSpecial = 4
							4:
								SpikeUp()
								AI_NextSpecial = 2


func _physics_process(delta): #Override this
	_AI(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

var GroundPos : float = 30
var TallPos : float = -95
var MidPos : float = -25
var LaserPos : Array[float] = [-25,-95,30]
@onready var LaserOne = $LaserOne
@onready var LaserTwo = $LaserOne2
var SetLasers : bool = false
func LaserCast():
	
	AnimPlayer.play("SpellCast")
	await AnimPlayer.animation_finished
	if not SetLasers:
		SetLasers = true
		var atkdata : AttackData = AttackData.new()
		atkdata.Damage = 15
		($LaserOne/Hurtbox as Hurtbox).StoredAttackData = atkdata
		var atkdata2 : AttackData = AttackData.new()
		atkdata2.Damage = 15
		($LaserOne/Hurtbox as Hurtbox).StoredAttackData = atkdata2
		
	LaserPos.shuffle()
	LaserOne.position.y = LaserPos[0]
	LaserTwo.position.y = LaserPos[1]
	BeamPlayer.play("BeamAnimation")
	AI_Phase = 0
	

func Swing():
	if (PlayerRef.global_position.y - global_position.y > -70): #we are on floor or platform 1
		AnimPlayer.play("Swing")
		await AnimPlayer.animation_finished
	AI_Phase = 0
	AI_Timer = 1.25
	
@onready var RockLocs : Array 
var Rock : PackedScene = preload("res://Entities/Enemy/Boss/Rock.tscn")
func Rockfall():
	if not is_instance_valid(RockLocs):
		RockLocs = get_tree().get_first_node_in_group("Rocks").get_children()
	
	AnimPlayer.play("Stomp")
	await AnimPlayer.animation_finished
		
	RockLocs.shuffle()
	for counter in range(6):
		var RockSpawn = Rock.instantiate()
		RockLocs[counter].add_child(RockSpawn)
	
	#wait animation
	AI_Phase = 0

@onready var Spikes : Array 
func SpikeUp():
	if not is_instance_valid(Spikes):
		Spikes = get_tree().get_first_node_in_group("Spikes").get_children()
	
	AnimPlayer.play("Stomp")
	await AnimPlayer.animation_finished
	
	get_tree().get_first_node_in_group("Spikes").visible = true
	for singlespike in Spikes:
		if singlespike is Spike:
			singlespike.SpikeUP()
	#wait animation
	AI_Phase = 0

@onready var FlashPlayer : AnimationPlayer = $FlashPlayer
func _Got_Hit(Data : AttackData):
	FlashPlayer.play("Flash")
	TakeDamage(Data.Damage)
	ApplySpecialEffects(Data)

func Die():
	$Hitbox/CollisionShape2D.set_deferred("disabled",true)
	velocity = Vector2.ZERO
	AI_Phase = 9
	AnimPlayer.play("Die")
	await AnimPlayer.animation_finished
	SignalBus.emit_signal("WIN")
