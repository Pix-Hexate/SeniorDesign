extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _AI():
	pass

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func Got_Hit(Data : AttackData):
	print("i got hit")
	$"Delete this - testing only".visible = true
	$"Delete this - testing only/Timer".start()

func delete_this_testing_only():
	$"Delete this - testing only".visible = false
