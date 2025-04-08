extends EnemyBaseScene



'''
3 Phase AI
1 - Actively Seeking and walking at player
2 - Stunned
3 - Wandering
4 - Wandering, but player within detection area

"base phase" is 3
When player enters detection radius, cast a raycast to see if the player is actually "visible" to the enemy
if they are, then enter 1

1 - Seeking
If player leaves, start timer, to enter 3
If player reenters, stop timer
If Player hits them, restart timer if they are outside, or stop if inside
Basically, the enemy only stops seeking after the player is outside their detection
radius for x seconds and dpe

2 - Got hit, and stunned for a brief period
immediately enter 1 after stun regardless distance

3 - Wandering
Walk left or right until
1 - There is no more floor, turn around - Enemies will drop down at most 4 blocks, not 5
2 - There's a block ahead of me, if I can jump up, jump 
3 - There's a block ahead of me and I can't jump it, turn around

4 - Wandering*
Player went inside detection, but not "Visible" due to collision blocking vision
In this state, start a timer to create a raycast to attempt to "re-detect" player every 1s
If player leaves, go back to 3
'''
var AI_Phase : int = 0 #default 3
var Want_Right : bool = true #Which way the enemy "wants" to go, and determines the way its facing
var Acceleration : float = 150 #takes slightly under 1s to get to max speed
var Max_Speed : float = 175 #Player is 250 for reference
var JumpStrength : float = 300 #Player is 250
var GravityStrength : float = 1200 #Player is 1200
var RecentlyTurned : bool = false
@onready var _Hurtbox : Hurtbox = $Hurtbox
@onready var Sprite : AnimatedSprite2D = $Sprite2D
@export var Damage : float = 20
@export var DIE_ON_HIT_TESTER : bool = false
@export var SLOW_TESTER : bool = false
@onready var AnimPlayer : AnimationPlayer = $AnimationPlayer

func _ready():
	var AtkData : AttackData = AttackData.new()
	AtkData.Damage = Damage
	_Hurtbox.StoredAttackData = AtkData
	
	Acceleration *= randf_range(.9, 1.1)
	Max_Speed *= randf_range(.9, 1.1)
	if SLOW_TESTER:
		Max_Speed *= .5

func Activate():
	if AI_Phase == 0:
		print("skele getting activated")
		AI_Phase = 3

func _AI(delta : float):#Override This
	match AI_Phase:
		1: #aggro
			Sprite.play("Walk")
			$TEST_PHASE_INDICATOR.text = "1"
			if PlayerRef.global_position.x > global_position.x:
				if not Want_Right:
					Want_Right = true
					FlipRayCasts()
			else:
				if Want_Right:
					Want_Right = false
					FlipRayCasts()
			if !$FloorRaycast.is_colliding(): #player has run off a ledge we can't follow, we drop aggro immediately
				AI_Phase = 3
				
				if not Want_Right:
					Want_Right = true
					FlipRayCasts()
					$TurnTimer.start(.25)
					RecentlyTurned = true
				else:
					if Want_Right:
						Want_Right = false
						FlipRayCasts()
						RecentlyTurned = true
						$TurnTimer.start(.25)
			else:
				if ($WallRaycast as RayCast2D).is_colliding(): #if we see a wall in front of us
					if not ($JumpRaycast as RayCast2D).is_colliding(): #we check if the wall is jumpable
						if is_on_floor(): #if it's jumpable, then we jump
							velocity.y -= JumpStrength
				#we don't turn cos we are aggro even if we are at a wall
			
			if Want_Right:
				if velocity.x < 0 : #this is essentially "friction", so they turn around quickly, but they still have some amount of "slow" when they turn around without a full stop which is jarring
					velocity.x *= pow(0.5, delta/.1)
				velocity.x += delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
			else:
				if velocity.x > 0 :
					velocity.x *= pow(0.5, delta/.1)
				velocity.x -= delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
		2: #stunned
			Sprite.play("Stunned")
			$TEST_PHASE_INDICATOR.text = "2"
			#do nothing
		3: #wander
			Sprite.play("Walk")
			$TEST_PHASE_INDICATOR.text = "3"
			
			if not $FloorRaycast.is_colliding():
				if Want_Right:
					Want_Right = false
					RecentlyTurned = true 
					$TurnTimer.start(.25)
					FlipRayCasts()
				else:
					Want_Right = true
					RecentlyTurned = true
					FlipRayCasts()
					$TurnTimer.start(.25)
					
			if ($WallRaycast as RayCast2D).is_colliding(): #if we hit a wall
				if not ($JumpRaycast as RayCast2D).is_colliding(): #if we can jump it
					if is_on_floor(): #we try to jump
						velocity.y -= JumpStrength
				else: #if we cant jump it 
					if not RecentlyTurned: #we turn around
						if Want_Right:
							Want_Right = false
							RecentlyTurned = true #this deals with some nonsense with colliders spamming turns at a wall
							$TurnTimer.start(.25)
							FlipRayCasts()
						else:
							Want_Right = true
							RecentlyTurned = true
							FlipRayCasts()
							$TurnTimer.start(.25)
			
			if Want_Right:
				if velocity.x < 0 : #this is essentially "friction", so they turn around quickly, but they still have some amount of "slow" when they turn around without a full stop which is jarring
					velocity.x *= pow(0.5, delta/.1)
				velocity.x += delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
			else:
				if velocity.x > 0 :
					velocity.x *= pow(0.5, delta/.1)
				velocity.x -= delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
		4: #this is basically a copy of 3, we need 4 though to know when to actively "look" for the player within aggro range
			Sprite.play("Walk")
			$TEST_PHASE_INDICATOR.text = "4"
			if not $FloorRaycast.is_colliding():
				if Want_Right:
					Want_Right = false
					RecentlyTurned = true 
					$TurnTimer.start(.25)
					FlipRayCasts()
				else:
					Want_Right = true
					RecentlyTurned = true
					FlipRayCasts()
					$TurnTimer.start(.25)
					
			if ($WallRaycast as RayCast2D).is_colliding(): #if we hit a wall
				if not ($JumpRaycast as RayCast2D).is_colliding(): #if we can jump it
					if is_on_floor(): #we try to jump
						velocity.y -= JumpStrength
				else: #if we cant jump it 
					if not RecentlyTurned: #we turn around
						if Want_Right:
							Want_Right = false
							RecentlyTurned = true #this deals with some nonsense with colliders spamming turns at a wall
							$TurnTimer.start(.25)
							FlipRayCasts()
						else:
							Want_Right = true
							RecentlyTurned = true
							FlipRayCasts()
							$TurnTimer.start(.25)
			
			if Want_Right:
				if velocity.x < 0 : #this is essentially "friction", so they turn around quickly, but they still have some amount of "slow" when they turn around without a full stop which is jarring
					velocity.x *= pow(0.5, delta/.1)
				velocity.x += delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
			else:
				if velocity.x > 0 :
					velocity.x *= pow(0.5, delta/.1)
				velocity.x -= delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
		0:
			pass
		_:
			
			print("ERROR IN WALKER ENEMY AI - AI is not 1-4? How is that even possible????")


func FlipRayCasts():
	if Want_Right:
		$JumpRaycast.target_position.x = 38
		$WallRaycast.target_position.x = 27
		$FloorRaycast.position.x = 28
		Sprite.flip_h = true
	else:
		$JumpRaycast.target_position.x = -38
		$WallRaycast.target_position.x = -27
		$FloorRaycast.position.x = -28
		Sprite.flip_h = false


func _physics_process(delta): #Override this
	_AI(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _Got_Hit(Data : AttackData): #Override This
	AnimPlayer.play("Flash")
	PlayerAggroTimer.stop()
	AI_Phase = 2
	velocity.x = 0
	StunTimer.start()
	$"Attempt Reaggro".stop()
	TakeDamage(Data.Damage)
	ApplySpecialEffects(Data)

func Die():
	$StunTimer.stop()
	$"Attempt Reaggro".stop()
	$PlayerAggroTimer.stop()
	$Hitbox/CollisionShape2D.set_deferred("disabled",true)
	$Sprite2D.material = null
	velocity = Vector2.ZERO
	AI_Phase = 9
	$Hurtbox/CollisionShape2D.set_deferred("disabled",true)
	var tw : Tween = get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0, 3)
	await tw.finished
	queue_free()

func delete_this_testing_only():
	$"Delete this - testing only".visible = false


func PlayerDetection(body: Node2D = null) -> void: #this ever only detects players anyways
	if PlayerRef.global_position.y <= global_position.y:
		PlayerRaycast.global_position = Vector2(global_position.x, PlayerRef.global_position.y)
	else:
		PlayerRaycast.global_position = global_position
	PlayerRaycast.target_position = to_local(PlayerRef.global_position) - PlayerRaycast.position
	PlayerRaycast.force_raycast_update()
	if PlayerRaycast.get_collider() is CharacterBaseScene:
		AI_Phase = 1
		print("seeing player")
		$"Attempt Reaggro".stop()
		$PlayerAggroTimer.stop()
	else:
		AI_Phase = 4
		#$PlayerAggroTimer.stop()
		$"Attempt Reaggro".start(2)
		print("not seeing player")
	
		
func PlayerDetection_Leave(body: Node2D) -> void:
	if body is CharacterBaseScene:
		print("saw player leaving")
		$PlayerAggroTimer.start(3)

func DropAggro() -> void:
	print("dropping aggro")
	AI_Phase = 3
	$"Attempt Reaggro".stop()

func EndStun() -> void:
	AI_Phase = 1

func CanTurn():
	RecentlyTurned = false
