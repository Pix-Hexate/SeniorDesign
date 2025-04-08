extends EnemyBaseScene

var AI_Timer : float = 0
@export var AI_Phase : int = 0: #default 1
	get:
		return AI_Phase
	set(value):
		AI_Phase = value
		AI_Timer = 0
		
@onready var _HurtBox : Hurtbox = $Hurtbox
@onready var _HitBox : Hitbox = $Hitbox

@export var IdleTime : float = 1
@export var FadeOutTime : float = 2
@export var PhaseOutTime : float = 3
var RandPhaseOutTime : float = 3
@export var FadeInTime : float = 1
@export var AggroIdleTime : float = .5
@export var DashTime : float = 1.5
@export var DashSpeed : float = 18000
@export var Direction : bool = true #true is right
@export var Damage : float = 25
var DashSine : float = 0
var FacingRight : bool = false

func _ready():
	var atkdata : AttackData = AttackData.new()
	atkdata.Damage = Damage
	_HurtBox.StoredAttackData = atkdata
	atkdata.Attacker = self
	
'''
AI is simple - 
Idle (start) -> If player is within range, teleport "behind" them -> Idle (aggro) -> Dash through them -> Idle (start)
Idle (start) -> If player is not within range, teleport slightly above the player to indicate to them that a ghost is in the area -> Idle (start)

Can be inturrupted at any point, after stun, go to fade out

Idle (start) - 1
Fading out - 2
Teleport (n/a, instant, called by fading done)
Fade in (plus short pause) - 3
Dashing - 4 
Stunned - 5
'''

func _AI(delta : float):#Override This
	AI_Timer += delta
	TickDamageTimer += delta
	if TickDamageTimer >= 1.0:  # Apply tick damage every second
		TickDamageTimer = 0
		ApplyTickDamage()
	match AI_Phase:
		1: #idle
			velocity = Vector2(0,0)
			$"Delete this - testing only".text = "1"
			if AI_Timer >= IdleTime:
				AI_Phase = 2
				PhaseOut()
		2: #fade out
			pass
		3:
			pass
		4:
			$"Delete this - testing only".text = "4"
			DashSine += delta
			var vertical_offset = sin(DashSine*PI*2/DashTime)*2900
			
			if FacingRight:
				$Sprite2D.flip_h = true
				velocity = Vector2(DashSpeed, vertical_offset)*delta
			else:
				$Sprite2D.flip_h = false
				velocity = Vector2(-DashSpeed, vertical_offset)*delta
			if AI_Timer >= DashTime:
				AI_Phase = 1
		5:
			pass
		0:
			pass

func PhaseOut():
	print("Phasing out")
	var tw : Tween = get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0, FadeOutTime)
	await tw.finished
	if AI_Phase == 2:
		RandPhaseOutTime = PhaseOutTime + randf_range(-1,1)
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		await get_tree().create_timer(RandPhaseOutTime).timeout
		PhaseIn()
		$"Delete this - testing only".text = "3"
	
func PhaseIn():
	print("phasing in")
	var PlayerLoc : Vector2 = PlayerRef.global_position
	if PlayerRef.FacingRight:
		global_position = PlayerLoc + Vector2(-200, -30)
		FacingRight = true
	else:
		FacingRight = false
		global_position = PlayerLoc + Vector2(200, -30)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	$Hitbox/CollisionShape2D.set_deferred("disabled", false)
	var tw : Tween = get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 1, FadeInTime)
	await tw.finished
	if AI_Phase == 2:
		Dash()

func Dash():
	AI_Phase = 4
	DashSine = 0

func _physics_process(delta): #Override this
	_AI(delta)
	move_and_slide()

func Activate():
	if AI_Phase == 0:
		AI_Phase = 1

func _Got_Hit(Data : AttackData): #Override This	
	velocity = Vector2(0,0)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	self_modulate.a = .5
	AI_Phase = 5
	StunTimer.start()
	TakeDamage(Data.Damage)
	ApplySpecialEffects(Data)

func Die():
	$Hitbox/CollisionShape2D.set_deferred("disabled",true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled",true)
	self_modulate.a = 1
	velocity = Vector2.ZERO
	AI_Phase = 9
	var tw : Tween = get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0, 3)
	await tw.finished
	queue_free()

	

func StunDone():
	AI_Phase = 1
