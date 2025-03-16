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
var Acceleration : float = 500 #takes slightly over .5s to get to max speed
var Max_Speed : float = 300 #Player is 250 for reference
var JumpStrength : float = 250 #Player is 250
var GravityStrength : float = 1200 #Player is 1200
@onready var StunTimer : Timer = $StunTimer
@onready var PlayerAggroTimer : Timer = $PlayerAggroTimer
@onready var WallDetector : RayCast2D = $"Wall Detector"
func _AI():#Override This
	match AI_Phase:
		1:
			$TEST_PHASE_INDICATOR.text = "1"
			
		2:
			$TEST_PHASE_INDICATOR.text = "2"
		3:
			$TEST_PHASE_INDICATOR.text = "3"
		4:
			$TEST_PHASE_INDICATOR.text = "4"
		_:
			print("ERROR IN WALKER ENEMY AI - AI is not 1-4? How is that even possible????")



func _physics_process(delta): #Override this
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

	WallDetector.global_position = Vector2(global_position.x, PlayerRef.global_position.y)
	WallDetector.target_position = to_local(PlayerRef.global_position) - WallDetector.position
	WallDetector.force_raycast_update()
	if WallDetector.get_collider() is CharacterBaseScene:
		print("seeing player")
	else:
		print("not seeing player")


func Got_Hit(Data : AttackData): #Override This
	PlayerAggroTimer.stop()
	AI_Phase = 2
	velocity.x = 0
	#TODO Knockback
	
	$"Delete this - testing only".visible = true
	$"Delete this - testing only/Timer".start()

func delete_this_testing_only():
	$"Delete this - testing only".visible = false


func PlayerDetection(body: Node2D = null) -> void: #this ever only detects players anyways
	if PlayerRef.global_position.y > global_position.y: #if player is under us, we always see him
		print("See Player")
	else: #if the player is over us, draw a line to them to see if we can see
		WallDetector.global_position = Vector2(global_position.x, PlayerRef.global_position.y)
		WallDetector.target_position = to_local(PlayerRef.global_position) - WallDetector.position
		WallDetector.force_raycast_update()
		if WallDetector.get_collider() is CharacterBaseScene:
			print("seeing player")
		else:
			print("not seeing player")
		
func PlayerDetection_Leave(body: Node2D) -> void:
	if body is CharacterBaseScene:
		$PlayerAggroTimer.start(3)

func DropAggro() -> void:
	AI_Phase = 3

func EndStun() -> void:
	AI_Phase = 1
