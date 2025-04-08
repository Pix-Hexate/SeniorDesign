class_name Knight extends CharacterBaseScene

# Character Specific Stats
#@export var CurrentAttackKnockback: float = 300.0
#@export var KnockbackMultiplier: float = 1.0 # Base knockback multiplier for whirlwind
#@export var BoostedKnockbackMultiplier: float = 1.5 # Knockback multiplier when boosted for whirlwind

@export var AbilityCooldowns: Dictionary = {
	"BasicAttack": AttackSpeedDelay, # Cooldown in seconds
	"AbilityOne": 2.0,  
	"AbilityTwo": 4.0,
	"AbilityThree": 6.0
}

# Track cooldown timers
var AbilityCooldownTimers: Dictionary = {}
@export var IsBoosted: bool = false
var WasBoosted = false
@export var IsInvulnerable: bool = false
var AttackBuffTimer: Timer
var BasicAttackBonusTimer: Timer
var RegeneratingShieldTimer: Timer
var RegeneratingShieldUp: bool = true
var BasicAttackBonusUp: bool = true
var regen_timer: float = 0.0
var is_crit = randf() < CritChance
@onready var attack_hitbox = $Hurtbox # Reference the Area2D

func _ready():
	# Initialize stats
	MaxHP = 100
	CritChance = 0.05 # crit chance percentage as decimal
	CritDamage = 1.5 # crit damage boost
	HealthRegen = 2 # HP regenerated per second
	Armor = 0 # flat damage reduction
	BaseAttackSpeedDelay = 0.25
	AttackSpeedDelay = 0.25 # Attack timer
	AttackDamage = 7.5
	CurrentHP = 100
	AttackKnockbackBase = 300.0
	ReflectDamage = 10.0
	# Initialize cooldown timers
	for ability in AbilityCooldowns.keys():
		var timer = Timer.new()
		timer.wait_time = AbilityCooldowns[ability]
		timer.one_shot = true
		timer.timeout.connect(_on_ability_cooldown.bind(ability))
		add_child(timer)
		AbilityCooldownTimers[ability] = timer
		
	# Timer for attack speed buff from Boosted
	AttackBuffTimer = Timer.new()
	AttackBuffTimer.wait_time = 4.0
	AttackBuffTimer.one_shot = true
	AttackBuffTimer.timeout.connect(_on_boost_expired)
	add_child(AttackBuffTimer)
	
	# Timer for regerating shield
	RegeneratingShieldTimer = Timer.new()
	RegeneratingShieldTimer.wait_time = 10.0
	RegeneratingShieldTimer.one_shot = true
	RegeneratingShieldTimer.timeout.connect(_on_shield_timer_ended)
	add_child(RegeneratingShieldTimer)
	
	# Timer for Basic Attack Bonus
	BasicAttackBonusTimer = Timer.new()
	BasicAttackBonusTimer.wait_time = 5.0
	BasicAttackBonusTimer.one_shot = true
	BasicAttackBonusTimer.timeout.connect(_on_basic_attack_bonus_timer_ended)
	add_child(BasicAttackBonusTimer)
	
	# Initialize attack
	attack_data.Damage = AttackDamage * (CritDamage if is_crit else 1)
	attack_data.Source = global_position
	attack_data.Attacker = self

func Process_Action_Inputs():
	match Buffered_Keys["Action"]:
		"BasicAttack":
			if not Playing_Action and AbilityCooldownTimers["BasicAttack"].is_stopped():
				BasicAttack()
		"AbilityOne":
			if not Playing_Action and AbilityCooldownTimers["AbilityOne"].is_stopped():
				Ability1Stab()
		"AbilityTwo":
			if not Playing_Action and AbilityCooldownTimers["AbilityTwo"].is_stopped():
				Ability2Block()
		"AbilityThree":
			if not Playing_Action and AbilityCooldownTimers["AbilityThree"].is_stopped() and IsBoosted == false:
				Ability4Boosted()
	Buffered_Keys["Action"] = ""  # Clear input after processing

func _on_ability_cooldown(ability_name: String):
	return
	print(ability_name + " is ready!")
	

func _process(delta: float) -> void:
	Take_Inputs()
	Process_Movement_Inputs()
	Process_Action_Inputs()
	regen_timer += delta
	if regen_timer >= 1.0:  # Apply health regen every second
		regen_timer = 0
		Heal(HealthRegen)
	if CooldownPickup:
		CooldownPickup = false
		UpdateCooldowns()

func Heal(amount: float):
	UpdateUI()
	CurrentHP = min(CurrentHP + amount, MaxHP)

@onready var HPBar : TextureProgressBar = get_tree().get_first_node_in_group("HPBar")
@onready var HPLabel : Label = get_tree().get_first_node_in_group("HPLabel")
func UpdateUI():
	HPLabel.text = str(CurrentHP) + "/" + str(MaxHP)
	HPBar.value = CurrentHP/MaxHP*100

func UpdateCooldowns():
	# Update cooldown times
	AbilityCooldowns["AbilityOne"] *= CooldownBonus
	AbilityCooldowns["AbilityTwo"] *= CooldownBonus
	AbilityCooldowns["AbilityThree"] *= CooldownBonus

	
	# Update cooldown timers
	for ability in AbilityCooldowns.keys():
		AbilityCooldownTimers[ability].wait_time = AbilityCooldowns[ability]
	
func _Got_Hit(Data: AttackData):
	if IsInvulnerable:
		print("Attack Blocked!")
		# If boosted, reflect damage
		AudioManager.QueueRandomizedSound("Blocked")
		if IsBoosted:
			_reflect_damage(Data)
		return
	if RegeneratingShieldUp and RegeneratingShield:
		print("Attack Blocked")
		RegeneratingShieldUp = false
		RegeneratingShieldTimer.start()
		return
		
	print("Took " + str(Data.Damage) + " damcage")
	AudioManager.QueueRandomizedSound("PlayerHit")
	var damage = max(Data.Damage - Armor, 1)
	CurrentHP -= damage
	UpdateUI()
	
	if CurrentHP <= 0:
		Die()

func SetAnimation() -> void:
	if not Playing_Action:
		if not is_on_floor(): #in the air
			if (velocity.y >= 15): #jump up
				AnimPlayer.play("JumpUp")
			elif (velocity.y <= 15): #jump down
				AnimPlayer.play("JumpDown")
			else: #jump mid
				AnimPlayer.play("JumpMid")
		#otherwise we're on the floor
		elif velocity.x != 0:
			AnimPlayer.play("Walk")
		else:
			AnimPlayer.play("Idle")


var QueuedTurn : bool = true
var WantFaceRight : bool = true
func Process_Movement_Inputs():
	if Buffered_Keys["Movement"] == "":
		if not is_on_floor():
			MovementVector *= .97
		else:
			MovementVector = 0
			
	if not Playing_Action:
		match Buffered_Keys["Movement"]:
			"LeftKey":
				Buffered_Keys["Movement"] = ""
				MovementVector = -1
				if FacingRight:
					FacingRight = false
					scale.x = -1
				
			"RightKey":
				Buffered_Keys["Movement"] = ""
				MovementVector = 1
				if not FacingRight:
					FacingRight = true
					scale.x = -1
	else:
		if not is_on_floor(): #if playing action and not on floor
			MovementVector*=.97
		else:
			MovementVector = 0
			
	if Buffered_Keys["Action"] == "Jump" and not Playing_Action:
		AttemptJump()
		
	SetAnimation()


func Die():
	print("Knight has fallen!")
	get_tree().get_first_node_in_group("DeathUI").visible = true
	get_tree().paused = true
	# Instead of deleting the player, transition to an end screen
	#var game_over_screen = preload("res://GameOver.tscn").instantiate()
	#get_tree().current_scene.add_child(game_over_screen)

# Handles boost expiration
func _on_boost_expired():
	print("Boost expired!")
	#AttackSpeedDelay /= 0.5
	#MoveSpeed /= 1.5
	#JumpStrength /= 1.2
	IsBoosted = false
	AbilityCooldownTimers["AbilityThree"].start()
	
# Handles shield timer expiration
func _on_shield_timer_ended():
	RegeneratingShieldUp = true

# Handles Bonus to Basic Attack is ready
func _on_basic_attack_bonus_timer_ended():
	BasicAttackBonusUp = true

func _apply_knockback(enemy):
	var direction = (enemy.global_position - global_position).normalized()
	enemy.apply_impulse(direction * AttackKnockbackBase)

func _pull_enemy_towards_player(enemy):
	print("Pulling Enemies")  
	var direction = (global_position - enemy.global_position).normalized()
	var pull_force = 500.0  # Adjust as needed
	enemy.apply_impulse(direction * pull_force)
	
func _reflect_damage(Data: AttackData):
	print("Reflecting damage!")	
	var attacker = Data.Attacker
	if attacker != null:
		if attacker.has_method("_Got_Hit"):
			attack_data.Damage = ReflectDamage
			attack_data.Knockback = Data.Knockback
			attack_data.Source = global_position
			attacker._Got_Hit(attack_data)  # Redirect the original damage
		return
	
func UpdateAnimationSpeed():
	# Ensure AttackSpeedDelay never goes to zero (to avoid division errors)
	AttackSpeedDelay = max(AttackSpeedDelay, 0.01)
	AnimPlayer.speed_scale = BaseAttackSpeedDelay / AttackSpeedDelay

# Add bonus damage when you have the item and the bonus ability damage for having abilities up
func CalcBonusDamage(Damage: float):
	TotalDamage = Damage
	if AbilityCooldownTimers["AbilityOne"].is_stopped():
		TotalDamage *= 1.5
	if AbilityCooldownTimers["AbilityTwo"].is_stopped():
		TotalDamage *= 1.5
	if AbilityCooldownTimers["AbilityThree"].is_stopped():
		TotalDamage *= 1.5

#region Attacks

'''
TODO - check all attack layouts
they should
1 - Make the relevant AttackData (if like boosted or not)
2 - Set the hurtbox AttackData (and if crit)
3 - Set the animationplayer speed
4 - Call the relevant animation
5 - Call Attack Cooldown
6 - Call the attack sound

Animation player modifies Playing_Action, handles hitbox movement and enabled/disabled
Hurtbox automatically calls hits to hitboxes, do not manually call hits in code
'''

@onready var _GameplayUI : GameplayUI = get_tree().get_first_node_in_group("GamePlayUI")

func BasicAttack():		
	#Playing_Action = true
	
	# Create attack data
	is_crit = randf() < CritChance
	
	# Check if the damage cooldown bonus item is picked up
	if AbilityDamageCooldownBonus:
		CalcBonusDamage(AttackDamage * (CritDamage if is_crit else 1))
	else:
		TotalDamage = AttackDamage * (CritDamage if is_crit else 1)
		
	attack_data.Damage = TotalDamage
	if KnockbackEnabled:
		attack_data.Knockback = AttackKnockbackBase
	attack_data.SpecialEffects = SpecialEffects
	attack_data.Source = global_position  # Set attack origin
	attack_hitbox.StoredAttackData = attack_data
		# Update attack animation speed
	UpdateAnimationSpeed()
	
	AnimPlayer.play("BasicAttack1")
	AudioManager.QueueRandomizedSound("Slash")
	# Enable hitbox temporarily
	'''
	attack_hitbox.monitoring = true
	attack_hitbox.StoredAttackData = attack_data
	
	if BasicAttackBonusUp and BasicAttackBonus:
		print("Basic Attack Bonus: Slashing forward!")
		# Trigger attack animation
		AnimPlayer.play("BasicAttackBonus")
		# Start Basic Attack Bonus Cooldown
		BasicAttackBonusTimer.start()
		BasicAttackBonusUp = false
	else:
		print("Basic Attack: Slashing forward!")
		# Trigger attack animation
		AnimPlayer.play("BasicAttack")
	
	# Apply attack to overlapping areas
	for area in attack_hitbox.get_overlapping_areas():
		if area is Hurtbox:  # Check if it's a valid Hurtbox
			area.Got_Hit(attack_data)  # Apply attack data to hurtbox
					
	# Disable hitbox after the attack
	attack_hitbox.monitoring = false
	Playing_Action = false
	'''
	# Start attack cooldown
	AbilityCooldownTimers["BasicAttack"].start()
		
	# Reset Animation Speed
	#AnimPlayer.speed_scale = 1
	
func Ability1Stab():	
	Playing_Action = true
	print("Ability 1: Stab!")
	
	# Create AttackData and assign values for this attack
	is_crit = randf() < CritChance
	
	# Check if the damage cooldown bonus item is picked up
	if AbilityDamageCooldownBonus:
		CalcBonusDamage(AttackDamage * 1.5 * (CritDamage if is_crit else 1))
	else:
		TotalDamage = AttackDamage * 1.5 * (CritDamage if is_crit else 1)
	
	attack_data.Damage = TotalDamage
	if IsBoosted:
		attack_data.Damage *= 1.5
	attack_data.SpecialEffects = SpecialEffects
	attack_data.Source = global_position
	attack_hitbox.StoredAttackData = attack_data
	
	if IsBoosted:
		print("Ability 1 when boosted")
		#attack_hitbox.scale *= 1.5  # Increase stab range
		#WasBoosted = true
	
	# Enable hitbox for attack detection
	#attack_hitbox.monitoring = true
	
	# Update attack animation speed
	UpdateAnimationSpeed()
	
	# Play stab animation
	AudioManager.QueueRandomizedSound("Stab")
	if not IsBoosted:
		AnimPlayer.play("Ability 1 - Thrust - Normal")
	else:
		AnimPlayer.play("Ability 1 - Thrust - Boosted")
		IsBoosted = false
		$BoostedCrown.visible = false
	# Check for enemies in range
	#for area in attack_hitbox.get_overlapping_areas():
	#	if area is Hurtbox:  # Check if it's a valid Hurtbox
	#		area.Got_Hit(attack_data)  # Apply attack data to hurtbox

	# If boosted, apply extra effects
	#if WasBoosted:
		#attack_hitbox.scale /= 1.5  # Reset the scale
		#IsBoosted = false
		#WasBoosted = false
		#attack_data.Knockback = 0
		
	# Disable hitbox after the attack
	#attack_hitbox.monitoring = false
	#Playing_Action = false
	#CurrentAttackKnockback = AttackKnockbackBase
	
	# Start cooldown
	AbilityCooldownTimers["AbilityOne"].start()
	_GameplayUI.SetStab(AbilityCooldownTimers["AbilityOne"].wait_time)
	# Reset Animation Speed
	AnimPlayer.speed_scale = 1

func Ability2Block():
	#Playing_Action = true
	print("Ability 2: Blocking!")
	
	# Play block animation
	AudioManager.QueueRandomizedSound("Shield")
	AnimPlayer.play("Ability 2 - Block")
	
	# Set invulnerability flag
	#IsInvulnerable = true #set by animation
	
	# Wait for a short duration of invulnerability
	#await get_tree().create_timer(0.5).timeout #set by animation
	#IsBoosted = false; #set by animation
	
	# Remove invulnerability
	#IsInvulnerable = false
	#IsBoosted = false
	#Playing_Action = false
	
	# Start cooldown
	AbilityCooldownTimers["AbilityTwo"].start()
	_GameplayUI.SetBlock(AbilityCooldownTimers["AbilityTwo"].wait_time)
'''
func Ability3WhilrwindSlash():
	#TODO NOT READY
	return
	
	Playing_Action = true
	print("Ability 3: Whirlwind!")

	var WhirlwindDamage = AttackDamage
	
	# Boosted effects (increased movement speed, range, etc.)
	if IsBoosted:
		WhirlwindDamage *= 1.5  # Increase damage for boosted whirlwind
		# KnockbackMultiplier = BoostedKnockbackMultiplier  # Increase knockback for boosted ability
		IsBoosted = false
		WasBoosted = true
		
	# Check if the damage cooldown bonus item is picked up
	if AbilityDamageCooldownBonus:
		CalcBonusDamage(WhirlwindDamage * 2.5 * (CritDamage if is_crit else 1))
	else:
		TotalDamage = WhirlwindDamage * 2.5 * (CritDamage if is_crit else 1)
	
	# Create AttackData and assign values for this attack
	is_crit = randf() < CritChance
	attack_data.Damage = TotalDamage
	if KnockbackEnabled and IsBoosted:
		attack_data.Knockback = AttackKnockbackBase * 1.5
		
	attack_data.SpecialEffects = SpecialEffects
	attack_data.Source = global_position
	attack_hitbox.StoredAttackData = attack_data

	# Enable hitbox temporarily
	attack_hitbox.monitoring = true
	
	# Play whirlwind animation
	AnimPlayer.play("AbilityThree")
	
	# Check for enemies in range
	for area in attack_hitbox.get_overlapping_areas():
		if area is Hurtbox:  # Check if it's a valid Hurtbox
			area.Got_Hit(attack_data)  # Apply attack data to hurtbox
	
	# Disable hitbox after the attack
	await get_tree().create_timer(2).timeout
	attack_hitbox.monitoring = false
	Playing_Action = false
	
	# Reset knockback
	attack_data.Knockback = 0
	
	# Start cooldown
	AbilityCooldownTimers["AbilityThree"].start()
'''

func Ability4Boosted():
	#Playing_Action = true
	# Play animation
	#AnimPlayer.play("AbilityFour")	#there is no animation
	IsBoosted = true
	$BoostedCrown.visible = true
	print("boosting")
	AbilityCooldownTimers["AbilityThree"].start()
	_GameplayUI.SetBoost(AbilityCooldownTimers["AbilityThree"].wait_time)
	
	#AttackSpeedDelay *= 0.5
	#MoveSpeed *= 1.5
	#JumpStrength *= 1.2
	AttackBuffTimer.start()
	#Playing_Action = false

#endregion


func _on_enemy_activater_body_entered(body):
	if body.has_method("Activate"):
		body.Activate()
