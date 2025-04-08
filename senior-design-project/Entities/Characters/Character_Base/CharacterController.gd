class_name CharacterBaseScene extends CharacterBody2D

'''Movement Stuff'''
@export var MovementVector : float = 0
@export var MoveSpeed : float = 250
@export var JumpStrength : float = 410 #370 default
@export var GravityStrength : float = 1200
@export var MaxHP: float = 100
@export var CurrentHP: float = 100
@export var Armor: float = 5.0 # flat damage reduction
@export var BaseAttackSpeedDelay: float = 0.3 # Attack timer
@export var AttackSpeedDelay: float = 0.3 # Attack timer
@export var AttackDamage: float = 5.0
@export var TotalDamage: float = 5.0
@export var CritChance: float = 0.05 # crit chance percentage as decimal
@export var CritDamage: float = 1.5 # crit damage boost
@export var HealthRegen: float = 5.0 # HP regenerated per second
@export var AttackKnockbackBase: float = 300.0
@export var ReflectDamage: float = 10.0
@export var BurnDamage: float = 0
@export var Lifesteal: float = 0
@export var CooldownBonus: float = 0
@export var CooldownPickup: bool = false
@export var DoubleJumpAvailable: bool = false
@export var RegeneratingShield: bool = false
@export var AbilityDamageCooldownBonus: bool = false
@export var KnockbackEnabled: bool = false
@export var BasicAttackBonus: bool = true
@export var attack_data = AttackData.new()
@export var SpecialEffects : Dictionary = {}
@onready var AnimPlayer : AnimationPlayer = $AnimationPlayer
@export var DoubleJumpReady: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Take_Inputs()

func _physics_process(delta: float) -> void: 
	Process_Movement_Physics(delta)
	Process_Movement_Inputs()
	Process_Action_Inputs()

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
		
	'''Attacks and Abilities'''
	if Input.is_action_pressed("BasicAttackKey"):
		Buffered_Keys["Action"] = "BasicAttack"
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

var FacingRight = true
@onready var Flipper : Marker2D = $Flipper
func Process_Movement_Inputs():
	MovementVector = 0
	match Buffered_Keys["Movement"]:
		"LeftKey":
			MovementVector = -1
			Buffered_Keys["Movement"] = ""
			if FacingRight:
				FacingRight = false
			
		"RightKey":
			MovementVector = 1
			Buffered_Keys["Movement"] = ""
			if not FacingRight:
				FacingRight = true
				
	if FacingRight and not Playing_Action:
		Flipper.scale.x = 1
	elif not FacingRight and not Playing_Action:
		Flipper.scale.x = -1
		
	if Buffered_Keys["Action"] == "Jump":
		AttemptJump()
		
	SetAnimation()

func AttemptJump() -> void:
	if is_on_floor():
		velocity.y = -JumpStrength
		Buffered_Keys["Action"] = ""
		DoubleJumpReady = true
		return
	if DoubleJumpReady and DoubleJumpAvailable:
		velocity.y = -JumpStrength
		Buffered_Keys["Action"] = ""
		DoubleJumpReady = false
		return
	
	
func Process_Action_Inputs():
	match Buffered_Keys["Action"]:
		"BasicAttack":
			if not Playing_Action:
				AnimPlayer.play("BasicAttack")
				Buffered_Keys["Action"] = ""
		"AbilityOne":
			if not Playing_Action:
				AnimPlayer.play("AbilityOne")
				Buffered_Keys["Action"] = ""
		"AbilityTwo":
			if not Playing_Action:
				AnimPlayer.play("AbilityTwo")
				Buffered_Keys["Action"] = ""
		"AbilityThree":
			if not Playing_Action:
				AnimPlayer.play("AbilityThree")
				Buffered_Keys["Action"] = ""
		"AbilityFour":
			if not Playing_Action:
				AnimPlayer.play("AbilityFour")
				Buffered_Keys["Action"] = ""
	
#example of how to spawn an item
func TEMPORARY_TEST_FUNC():
	var item = load("res://Entities/Items/Item_Object.tscn")
	var item_2 = item.instantiate()
	item_2.Data = GameManager.All_Items[0]
	item_2.global_position = global_position
	get_parent().add_child(item_2)

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


func _Got_Hit(Data : AttackData):
	pass

func BufferTimeout():
	Buffered_Keys["Action"] = ""
	
# Applies modifiers after picking up items
func ApplyUpgrade(Upgrade : Item_Data):
	for effect in Upgrade.Effects:
		match effect:
			"Move":
				MoveSpeed += Upgrade.Effects[effect]
			"Jump":
				JumpStrength += Upgrade.Effects[effect]
			"MaxHP":
				MaxHP += Upgrade.Effects[effect]
			"Armor":
				Armor += Upgrade.Effects[effect]
			"AttackSpeed":
				AttackSpeedDelay *= Upgrade.Effects[effect]
			"AttackDamage":
				AttackDamage += Upgrade.Effects[effect]
			"CritChance":
				CritChance += Upgrade.Effects[effect]
			"CritDamage":
				CritDamage += Upgrade.Effects[effect]
			"HealthRegen":
				HealthRegen += Upgrade.Effects[effect]
			"RegeneratingShield":
				RegeneratingShield = true
			"DoubleJump":
				DoubleJumpAvailable = true
			"CooldownBonusDamage":
				AbilityDamageCooldownBonus = true
			"BurnDamage":
				BurnDamage += Upgrade.Effects[effect]
				if not SpecialEffects.has("BurnDamage"):
					SpecialEffects["BurnDamage"] = 0
				SpecialEffects["BurnDamage"] += Upgrade.Effects[effect]
			"Lifesteal":
				Lifesteal = Upgrade.Effects[effect]
				if not SpecialEffects.has("Lifesteal"):
					SpecialEffects["Lifesteal"] = 0
				SpecialEffects["Lifesteal"] += Upgrade.Effects[effect]
			"Knockback":
				KnockbackEnabled = true
			"CoolDown":
				CooldownPickup = true
				CooldownBonus = Upgrade.Effects[effect]
			"BasicAttackBonus":
				BasicAttackBonus = true
			_:
				print("Unknown effect in ApplyUpgrade, it is " + str(effect))
	
