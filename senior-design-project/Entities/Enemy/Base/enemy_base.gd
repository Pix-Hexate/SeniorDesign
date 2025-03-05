class_name EnemyBaseScene extends CharacterBody2D

@onready var PlayerRef : CharacterBaseScene = get_tree().get_first_node_in_group("Player")

func _physics_process(delta): #Override this
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _AI():#Override This
	pass


func Got_Hit(Data : AttackData): #Override This
	print("i got hit")
	$"Delete this - testing only".visible = true
	$"Delete this - testing only/Timer".start()

func delete_this_testing_only():
	$"Delete this - testing only".visible = false


func PlayerDetection(body: Node2D) -> void: #override this
	pass # Replace with function body.

func PlayerDetection_Leave(body: Node2D) -> void:
	pass # Replace with function body.
