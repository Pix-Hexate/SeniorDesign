class_name KnightCharacterClass extends CharacterBody2D

'''Movement Stuff'''
var MovementVector : Vector2 = Vector2(0,0)
var XMovementSpeed : float = 1000
var JumpStrength : float = 1000
var GravityStrengh : float = 3000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	MovementVector.x = 0
	if Input.is_action_pressed("LeftKey"):
		MovementVector -= Vector2(1,0)
	if Input.is_action_pressed("RightKey"):
		MovementVector += Vector2(1,0)
	if Input.is_action_just_pressed("UpKey"):
		Jump()
	
func Jump() -> void:
	var canjump = true #to add canjump logic later #TODO
	if canjump:
		MovementVector -= Vector2(0,JumpStrength)
	
func _physics_process(delta: float) -> void:
	if MovementVector.y <= 0:
		MovementVector.y = clampf(MovementVector.y+GravityStrengh*delta,-9999,0)
	
	velocity = Vector2(MovementVector.x*XMovementSpeed, MovementVector.y)
	move_and_slide()
	
