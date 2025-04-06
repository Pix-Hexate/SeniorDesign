extends EnemyBaseScene



'''
AI is very simple

Check if player is on same level as golem, or under, if so, walk towards them -- infinite aggro
If not, idle

When in range of player, activate attack animation, and repeat

1. Idle
2. Walk towards Player
3. Attack (not actually a phase), 
4. Idle after attack

This big enemy does not care for your hitstun whatsoever, it does not get stunned
This bruh cannot jump, obviously, so it cant go up in elevation
'''
var Curr_Speed : float = 0
var Acceleration : float = 75 
var Max_Speed : float = 200 #Player is 250 for reference
var AI_Phase : int = 1 #idle
var Dist_to_Player : float = 0
var WantRight : bool = true
@export var Damage : float = 35
@onready var _Hurtbox : Area2D = $CustomHurtBox
var AtkData : AttackData

func _ready():
	AtkData = AttackData.new()
	AtkData.Damage = Damage

var ForceIdleTime : float = 0
func _AI(delta : float):
	match AI_Phase:
		1: #idle
			if PlayerRef.position.y+10 >= position.y: #swap to aggro if above player
				AI_Phase = 2
			velocity = Vector2.ZERO
			$"Delete this - testing only".text = "1"
			#idle animation
		2: #aggro
			$"Delete this - testing only".text = "2"
			if PlayerRef.global_position.y+10 < global_position.y:
				AI_Phase = 1
			
			if PlayerRef.global_position.x > global_position.x:
				WantRight = true
			else:
				WantRight = false
			
			if WantRight: #movement towards player
				if velocity.x < 0 : #this is essentially "friction", so they turn around quickly, but they still have some amount of "slow" when they turn around without a full stop which is jarring
					velocity.x *= pow(0.5, delta/.1)
				velocity.x += delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
			else:
				if velocity.x > 0 :
					velocity.x *= pow(0.5, delta/.1)
				velocity.x -= delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
				
			if global_position.distance_to(PlayerRef.global_position) <= 50:
				AI_Phase = 3
				Attack()
			
		3: #in attack animation
			velocity = Vector2.ZERO
		4: #force idle after attack
			velocity = Vector2.ZERO
			$"Delete this - testing only".text = "4"
			ForceIdleTime += delta
			if ForceIdleTime > 2.5:
				AI_Phase = 2
			
		

func Attack():
	print("preping attack")
	$"Delete this - testing only".text = "Prepping Attack"
	
	await get_tree().create_timer(1.5).timeout #replace this with await animation finished
	for area in _Hurtbox.get_overlapping_areas():
		if area is Hitbox:
			area._Got_Hit(AtkData)
			print("hitting things")
	AI_Phase = 4
	ForceIdleTime = 0
	

func _physics_process(delta): #Override this
	_AI(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
