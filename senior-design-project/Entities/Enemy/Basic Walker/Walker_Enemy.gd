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
Basic behavior if player is outside of radius

4 - Wandering*
Player went inside detection, but not "Visible" due to collision blocking vision
In this state, start a timer to create a raycast to attempt to "re-detect" player every 1s
If player leaves, go back to 3
'''
var AI_Phase : int = 3
var Want_Right : bool = true #Which way the enemy "wants" to go, and determines the way its facing
var Curr_Speed : float = 0
var Acceleration : float = 300 #takes slightly under 1s to get to max speed
var Max_Speed : float = 275 #Player is 250 for reference
var JumpStrength : float = 250 #Player is 250
var GravityStrength : float = 1200 #Player is 1200
var RecentlyTurned : bool = false
@onready var StunTimer : Timer = $StunTimer
@onready var PlayerAggroTimer : Timer = $PlayerAggroTimer
@onready var PlayerRaycast : RayCast2D = $"PlayerRaycast"

func _AI(delta : float):#Override This
	match AI_Phase:
		1: #aggro
			$TEST_PHASE_INDICATOR.text = "1"
			if PlayerRef.global_position.x > global_position.x:
				if not Want_Right:
					Want_Right = true
					FlipRayCasts()
			else:
				if Want_Right:
					Want_Right = false
					FlipRayCasts()
				
			if ($WallRaycast as RayCast2D).is_colliding():
				if not ($JumpRaycast as RayCast2D).is_colliding():
					if is_on_floor():
						velocity.y -= JumpStrength
						print("trying to jump")	
			
			if Want_Right:
				velocity.x += delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
			else:
				velocity.x -= delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
		2: #stunned
			$TEST_PHASE_INDICATOR.text = "2"
			#do nothing
		3: #wander
			$TEST_PHASE_INDICATOR.text = "3"
			
			if ($WallRaycast as RayCast2D).is_colliding():
				if not ($JumpRaycast as RayCast2D).is_colliding():
					if is_on_floor():
						velocity.y -= JumpStrength
						print("trying to jump")
				else:
					if not RecentlyTurned:
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
			
			if Want_Right:
				velocity.x += delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
			else:
				velocity.x -= delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
		4: #wander
			$TEST_PHASE_INDICATOR.text = "4"
			$WallRaycast.force_raycast_update()
			if ($WallRaycast as RayCast2D).is_colliding():
				$JumpRaycast.force_raycast_update()
				if not ($JumpRaycast as RayCast2D).is_colliding():
					if is_on_floor():
						velocity.y -= JumpStrength
						print("trying to jump")
				else:
					if not RecentlyTurned:
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
			
			if Want_Right:
				velocity.x += delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
			else:
				velocity.x -= delta * Acceleration
				velocity.x = clampf(velocity.x, -Max_Speed, Max_Speed)
		_:
			
			print("ERROR IN WALKER ENEMY AI - AI is not 1-4? How is that even possible????")


func FlipRayCasts():
	if Want_Right:
		$JumpRaycast.target_position.x = 38
		$WallRaycast.target_position.x = 27
	else:
		$JumpRaycast.target_position.x = -38
		$WallRaycast.target_position.x = -27

func _physics_process(delta): #Override this
	_AI(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func Got_Hit(Data : AttackData): #Override This
	PlayerAggroTimer.stop()
	AI_Phase = 2
	velocity.x = 0
	StunTimer.start()
	#TODO flash white
	#TODO Knockback
	$"Attempt Reaggro".stop()


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
