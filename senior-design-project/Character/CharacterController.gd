class_name KnightCharacterClass extends CharacterBody2D

'''Movement Stuff'''
var MovementVector : float = 0
var MoveSpeed : float = 500
var JumpStrength : float = 1000
var GravityStrength : float = 3000
@onready var Sprite : AnimatedSprite2D = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	MovementVector = 0
	if Input.is_action_pressed("LeftKey"): #we take the input keys to make a left/right "vector", and later on multiply the vector by movespeed to actually move
		MovementVector -= 1
	if Input.is_action_pressed("RightKey"):
		MovementVector += 1
	if Input.is_action_just_pressed("UpKey"): 
		AttemptJump()
	SetAnimation()
	
func AttemptJump() -> void:
	var canjump = true #to add canjump logic later #TODO
	if canjump and is_on_floor():
		velocity.y -= JumpStrength
	
func _physics_process(delta: float) -> void: 
	velocity.y += GravityStrength*delta
	if MovementVector:
		velocity.x = MovementVector*MoveSpeed
	
	velocity.x = velocity.x * .75 #minor slide, not even sure if we want this
	if abs(velocity.x) <= 25: 
		velocity.x = 0
		
	move_and_slide()
	
# I'm considering whether or not we'll need a state machine for our animations, or whether or not we can just use base code logic, I think we can get away with no FSM?

#First, check if going up or down, those always come first
#Then, check if walking, if not walking or up or down, then idle
func SetAnimation() -> void:
	if ((not is_on_floor()) and (velocity.y >= 0)):
		print("playing jumpdown")
		Sprite.play("jumpdown")
	elif velocity.y < 0:
		Sprite.play("jumpup")
	elif velocity.x != 0:
		Sprite.play("walk")
	else:
		Sprite.play("idle")
