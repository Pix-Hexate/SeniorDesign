class_name CharacterBaseScene extends CharacterBody2D

'''Movement Stuff'''
var MovementVector : float = 0
var MoveSpeed : float = 500
var JumpStrength : float = 1500
var GravityStrength : float = 6000
@onready var AnimPlayer : AnimationPlayer = $AnimationPlayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Take_Inputs()
	Process_Movement_Inputs()
	Process_Action_Inputs()

func _physics_process(delta: float) -> void: 
	Process_Movement_Physics(delta)

var Buffered_Keys : Dictionary = {"Movement" : "", "Action" : ""}
@export var Playing_Action : bool = false
@onready var BufferTimer : Timer = $InputBufferTimer
#There will be two key - value pairings
#movement, and "action"
func Take_Inputs(): #This function is our input buffer
	'''Movement'''
	if Input.is_action_pressed("LeftKey"): 
		Buffered_Keys["Movement"] = "LeftKey"
	if Input.is_action_pressed("RightKey"):
		if Buffered_Keys["Movement"] == "LeftKey":
			Buffered_Keys["Movement"] = ""
		else:
			Buffered_Keys["Movement"] = "RightKey"
	if Input.is_action_just_pressed("UpKey"): 
		Buffered_Keys["Action"] = "Jump"
		BufferTimer.start()
		
	
	if Input.is_action_pressed("AbilityOneKey"):
		Buffered_Keys["Action"] = "AbilityOne"
		BufferTimer.start()
	if Input.is_action_pressed("AbilityTwoKey"):
		Buffered_Keys["Action"] = "AbilityTwo"
		BufferTimer.start()
	if Input.is_action_pressed("AbilityThreeKey"):
		Buffered_Keys["Action"] = "AbilityThree"
		BufferTimer.start()
	if Input.is_action_pressed("AbilityFourKey"):
		Buffered_Keys["Action"] = "AbilityFour"
		BufferTimer.start()

func Process_Movement_Inputs():
	MovementVector = 0
	match Buffered_Keys["Movement"]:
		"LeftKey":
			MovementVector = -1
			Buffered_Keys["Movement"] = ""
		"RightKey":
			MovementVector = 1
			Buffered_Keys["Movement"] = ""
		
	if Buffered_Keys["Action"] == "Jump":
		AttemptJump()
		
	SetAnimation()

func AttemptJump() -> void:
	var canjump = true #to add canjump logic later #TODO
	if canjump and is_on_floor():
		velocity.y -= JumpStrength
		Buffered_Keys["Action"] = ""
	
func Process_Action_Inputs():
	match Buffered_Keys["Action"]:
		"AbilityOne":
			if not Playing_Action:
				AnimPlayer.play("AbilityOne")
				Buffered_Keys["Action"] = ""
		"AbilityTwo":
			if not Playing_Action:
				AnimPlayer.play("AbilityTwo")
				Buffered_Keys["Action"] = ""
		"AbilityThree":
			pass
		"AbilityFour":
			pass
	

func Process_Movement_Physics(delta : float):
	velocity.y += GravityStrength*delta
	velocity.y = clampf(velocity.y, -9999, 1000) #clamp downwards fall velocity
	if MovementVector:
		velocity.x = MovementVector*MoveSpeed
	
	velocity.x = velocity.x * .75 #minor slide, not even sure if we want this
	if abs(velocity.x) <= 25: 
		velocity.x = 0
		
	move_and_slide()

#First, check if going up or down, those always come first
#Then, check if walking, if not walking or up or down, then idle
func SetAnimation() -> void:
	if not Playing_Action:
		if ((not is_on_floor()) and (velocity.y >= 0)):
			AnimPlayer.play("JumpDown")
		elif velocity.y < 0:
			AnimPlayer.play("JumpUp")
		elif velocity.x != 0:
			AnimPlayer.play("Walk")
		else:
			AnimPlayer.play("Idle")


func BufferTimeout():
	Buffered_Keys["Action"] = ""
