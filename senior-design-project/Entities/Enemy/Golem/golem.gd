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
var Acceleration : float = 50 
var Max_Speed : float = 200 #Player is 250 for reference
@export var AI_Phase : int = 0 #default is 1
var Dist_to_Player : float = 0
var WantRight : bool = true
@export var Damage : float = 35
@onready var _Hurtbox : Hurtbox = $CustomHurtBox
var AtkData : AttackData

func _ready():
	AtkData = AttackData.new()
	AtkData.Damage = Damage
	_Hurtbox.StoredAttackData = AtkData

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
			AnimPlayer.play("Walk")
			$"Delete this - testing only".text = "2"
			if PlayerRef.global_position.y+10 < global_position.y:
				AI_Phase = 1
			
			if PlayerRef.global_position.x > global_position.x:
				WantRight = true
				$Sprite2D.flip_h = true
			else:
				WantRight = false
				$Sprite2D.flip_h = false
			
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
			if ForceIdleTime > 1.5:
				AI_Phase = 2
			
		
func Activate():
	if AI_Phase == 0:
		AI_Phase = 1

@onready var AnimPlayer : AnimationPlayer = $AnimationPlayer
func Attack():
	AnimPlayer.play("Attack")
	await AnimPlayer.animation_finished
	ForceIdleTime = 0
	
@onready var FlashPlayer : AnimationPlayer = $FlashPlayer
func _Got_Hit(Data : AttackData): #Override This
	FlashPlayer.play("Flash")
	TakeDamage(Data.Damage)
	ApplySpecialEffects(Data)

func Die():
	$Sprite2D.material = null
	$Hitbox/CollisionShape2D.set_deferred("disabled",true)
	velocity = Vector2.ZERO
	AI_Phase = 9
	var tw : Tween = get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0, 3)
	await tw.finished
	queue_free()


func _physics_process(delta): #Override this
	_AI(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
