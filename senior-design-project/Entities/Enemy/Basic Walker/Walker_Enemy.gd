extends EnemyBaseScene



'''
3 Phase AI
1 - Actively Seeking and walking at player
2 - Stunned
3 - Wandering
4 - Wandering, but player within detection area

3 <-> 4
3,4 -> 1
1 -> 2,3,4
2 -> 1 
'''
var AI_Phase : int = 3
var Want_Right : bool = true #Which way the enemy "wants" to go, and determines the way its facing
var Curr_Speed : float = 0
var Acceleration : float = 500 #takes slightly over .5s to get to max speed
var Max_Speed : float = 300 #Player is 250 for reference
var JumpStrength : float = 250 #Player is 250
var GravityStrength : float = 1200 #Player is 1200
func _AI():#Override This
	match AI_Phase:
		1:
			pass
		2:
			pass
		3:
			pass
		_:
			print("ERROR IN ENEMY AI - AI is not 1-3? How is that even possible????")



func _physics_process(delta): #Override this
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func Got_Hit(Data : AttackData): #Override This
	print("i got hit")
	$"Delete this - testing only".visible = true
	$"Delete this - testing only/Timer".start()

func delete_this_testing_only():
	$"Delete this - testing only".visible = false


func PlayerDetection(body: Node2D) -> void: #override this
	if body is CharacterBaseScene: #need a raycast to make sure there's no terrain in the way
		AI_Phase = 1
		$PlayerAggroTimer.stop()
		
func PlayerDetection_Leave(body: Node2D) -> void:
	if body is CharacterBaseScene:
		$PlayerAggroTimer.start(3)

func DropAggro() -> void:
	AI_Phase = 3
