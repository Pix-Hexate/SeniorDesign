class_name Knight extends CharacterBaseScene

# Character Stats
@export var MaxHP: int = 100
@export var CurrentHP: int = 100
@export var CritChance: float = 0.05 # 5% crit chance
@export var CritDamage: float = 1.5 # +50% crit damage
@export var HealthRegen: float = 5.0 # HP regenerated per second
@export var Armor: float = 5.0
@export var AttackSpeedDelay: float = 0.3 # Attack timer
@export var AttackDamage: float = 5.0
@export var attack_data = AttackData.new()
@export var AttackKnockbackBase: float = 300.0
@export var CurrentAttackKnockback: float = 300.0
@export var ReflectDamage: float = 10.0
@export var WhirlwindSlashDuration: float = 3.0 # Time the ability lasts
@export var WhirlwindSpeed: float = 200.0 # Speed of movement during whirlwind
@export var WhirlwindDamage: int = 15 # Damage per hit during whirlwind
@export var KnockbackMultiplier: float = 1.0 # Base knockback multiplier
@export var BoostedKnockbackMultiplier: float = 1.5 # Knockback multiplier when boosted
@export var AbilityCooldowns: Dictionary = {
	"BasicAttack": AttackSpeedDelay, # Cooldown in seconds
	"AbilityOne": 2.0,  
	"AbilityTwo": 5.0,
	"AbilityThree": 10.0,
	"AbilityFour": 1.0
}

# Track cooldown timers
var AbilityCooldownTimers: Dictionary = {}
var IsBoosted: bool = false
var WasBoosted = false
var IsInvulnerable: bool = false
var AttackBuffTimer: Timer
var is_whirlwind_active: bool = false
var whirlwind_timer: Timer
var original_attack_speed: float
var is_crit = randf()
@onready var attack_hitbox = $Flipper/Sprite2D/Hurtbox # Reference the Area2D

func _ready():
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
	AttackBuffTimer.wait_time = 5.0
	AttackBuffTimer.one_shot = true
	AttackBuffTimer.timeout.connect(_on_boost_expired)
	add_child(AttackBuffTimer)
	
	# Initialize attack
	attack_data.Damage = AttackDamage * (CritDamage if is_crit else 1)
	attack_data.Knockback = AttackKnockbackBase
	attack_data.Source = global_position
	attack_data.Attacker = self
	
	# Connect attack hitbox detection
	#attack_hitbox.area_entered.connect(_on_attack_hitbox_entered)

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
			if not Playing_Action and AbilityCooldownTimers["AbilityThree"].is_stopped():
				Ability3WhilrwindSlash()
		"AbilityFour":
			if not Playing_Action and AbilityCooldownTimers["AbilityFour"].is_stopped() and IsBoosted == false:
				Ability4Boosted()
	Buffered_Keys["Action"] = ""  # Clear input after processing

func _on_ability_cooldown(ability_name: String):
	print(ability_name + " is ready!")
	
var regen_timer: float = 0.0

func _process(delta: float) -> void:
	Take_Inputs()
	Process_Movement_Inputs()
	Process_Action_Inputs()
	regen_timer += delta
	if regen_timer >= 1.0:  # Apply health regen every second
		regen_timer = 0
		Heal(HealthRegen)
'''		
func _process(delta: float) -> void:
	Process_Action_Inputs() #why was this removed from _process?
	regen_timer += delta
	if regen_timer >= 1.0:  # Apply health regen every second
		regen_timer = 0
		Heal(HealthRegen)
		
	#if is_whirlwind_active: #TODO this needs to be redone
		# Rotate the player character
		#rotation += WhirlwindSpeed * delta #no we don't rotate the player

		# Move the player in the direction they're facing
		#var direction = Vector2(cos(rotation), sin(rotation))
		#global_position += direction * WhirlwindSpeed * delta

		# Hit detection with enemies in the range
		#_check_for_hits_in_whirlwind()
'''
func Heal(amount: float):
	CurrentHP = min(CurrentHP + amount, MaxHP)

func _Got_Hit(Data: AttackData):
	if IsInvulnerable:
		print("Attack Blocked!")
		# If boosted, reflect damage
		if IsBoosted:
			_reflect_damage(Data)
		return
	print("Took " + str(Data.Damage) + " damage")
	var damage = max(Data.Damage - Armor, 1)
	CurrentHP -= damage
	print(CurrentHP)
	#TODO Knockback
	
	if CurrentHP <= 0:
		Die()

func Die():
	print("Knight has fallen!")
	# Instead of deleting the player, transition to an end screen
	#var game_over_screen = preload("res://GameOver.tscn").instantiate()
	#get_tree().current_scene.add_child(game_over_screen)

# Handles boost expiration
func _on_boost_expired():
	print("Boost expired!")
	AttackSpeedDelay /= 0.5
	MoveSpeed /= 1.5
	JumpStrength /= 1.2
	IsBoosted = false
	AbilityCooldownTimers["AbilityFour"].start()
	

func _apply_knockback(enemy):
	var direction = (enemy.global_position - global_position).normalized()
	enemy.apply_impulse(direction * CurrentAttackKnockback)

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
	
	# Stop whirlwind after its duration
func _on_whirlwind_end():
	is_whirlwind_active = false
	
	if !WasBoosted:
		MoveSpeed /= 1.5  # Increase movement speed
		WhirlwindDamage /= 1.5
		WasBoosted = false
		
	# Reset knockback multiplier
	KnockbackMultiplier = 1.0
	CurrentAttackKnockback = AttackKnockbackBase
	AttackSpeedDelay = original_attack_speed
	AbilityCooldownTimers["AbilityThree"].start()
	print("Whirlwind Slash ended!")
		
func _start_whirlwind_movement(): #we do NOT want to rotate the player, it'll be an animation
	pass
	# Logic to rotate the player and move forward while spinning
	#var rotation_speed: float = 5.0  # Speed of rotation
	
	# Add a process to rotate and move while the ability is active
	#set_process(true) #what even is this?

func _check_for_hits_in_whirlwind():
	# Check for collision with enemies during the whirlwind
	for enemy in attack_hitbox.get_overlapping_areas():
		if enemy.is_in_group("Enemies"):
			# Apply damage and knockback
			enemy.TakeDamage(WhirlwindDamage)
			_apply_Whirlwind_knockback(enemy)
			
	
func _apply_Whirlwind_knockback(enemy):
	# Calculate direction of knockback
	var direction = (enemy.global_position - global_position).normalized()
	var knockback_force = AttackKnockbackBase * KnockbackMultiplier
	enemy.apply_impulse(direction * knockback_force)

func _start_whirlwind_damage():
	var damage_timer = Timer.new()
	damage_timer.wait_time = 0.3  # Apply damage every 0.3 seconds
	damage_timer.one_shot = false
	damage_timer.timeout.connect(_check_for_hits_in_whirlwind)
	add_child(damage_timer)
	damage_timer.start()
	
	# Stop damage application when whirlwind ends
	await get_tree().create_timer(WhirlwindSlashDuration).timeout
	damage_timer.queue_free()
	
#region Attacks
#why aren't any of the attacks calling setting PlayingAction?

func BasicAttack():
	print("Basic Attack: Slashing forward!")
	# Create attack data
	is_crit = randf() < CritChance
	attack_data.Damage = AttackDamage * (CritDamage if is_crit else 1)
	attack_data.Knockback = AttackKnockbackBase
	attack_data.Source = global_position  # Set attack origin
	
	# Enable hitbox temporarily
	attack_hitbox.monitoring = true
	attack_hitbox.StoredAttackData = attack_data
	
	# Trigger attack animation
	AnimPlayer.play("BasicAttack")
	
	# Apply attack to overlapping areas
	for area in attack_hitbox.get_overlapping_areas():
		if area is Hurtbox:  # Check if it's a valid Hurtbox
			area.Got_Hit(attack_data)  # Apply attack data to hurtbox
				
	# Start attack cooldown
	AbilityCooldownTimers["BasicAttack"].start()
	
	# Wait for attack delay, then disable hitbox
	await get_tree().create_timer(0.1).timeout
	attack_hitbox.monitoring = false
	
func Ability1Stab():
	print("Ability 1: Stab!")
	
	# Create AttackData and assign values for this attack
	is_crit = randf() < CritChance
	attack_data.Damage = AttackDamage * 1.5 * (CritDamage if is_crit else 1)
	attack_data.Knockback = IsBoosted if -200 else 1
	attack_data.Source = global_position
	attack_hitbox.StoredAttackData = attack_data
	if IsBoosted:
		print("Ability 1 when boosted")
		attack_hitbox.scale *= 1.5  # Increase stab range
		WasBoosted = true
	
	# Enable hitbox for attack detection
	attack_hitbox.monitoring = true
	
	# Play stab animation
	AnimPlayer.play("AbilityOne")
	
	# Wait for a brief moment to allow the hitbox to detect enemies
	await get_tree().create_timer(0.2).timeout  # Adjust timing as needed
	
	
				 
	
	# Check for enemies in range
	for area in attack_hitbox.get_overlapping_areas():
		if area.is_in_group("Enemies"):
			var enemy = area.get_parent()
			# Send the attack data to the enemy's hurtbox
			var enemy_hurtbox = enemy.get_node("Hurtbox")
			if enemy_hurtbox:
				enemy_hurtbox.Got_Hit(attack_data)  # Pass the attack data to the hurtbox

	# If boosted, apply extra effects
	if WasBoosted:
		attack_hitbox.scale /= 1.5  # Reset the scale
		IsBoosted = false
		WasBoosted = false
				
	# Disable hitbox after the attack
	attack_hitbox.monitoring = false
	CurrentAttackKnockback = AttackKnockbackBase
	
		# Start cooldown
	AbilityCooldownTimers["AbilityOne"].start()

func Ability2Block():
	if Playing_Action:
		return
	Playing_Action = true
	print("Ability 2: Blocking!")
	
	# Play block animation
	AnimPlayer.play("AbilityTwo")
	
	# Set invulnerability flag
	IsInvulnerable = true
	
	# Wait for a short duration of invulnerability
	await get_tree().create_timer(0.5).timeout
	IsBoosted = false;
	
	# Remove invulnerability
	IsInvulnerable = false
	IsBoosted = false
	Playing_Action = false
	
	# Start cooldown
	AbilityCooldownTimers["AbilityTwo"].start()

func Ability3WhilrwindSlash():
	if Playing_Action or is_whirlwind_active:
		return  # Prevent spamming the ability if already active

	is_whirlwind_active = true
	original_attack_speed = AttackSpeedDelay  # Store original attack speed

	# Adjust attack speed (decreased cooldown for basic attack while spinning)
	AttackSpeedDelay *= 0.5  # Faster attacks during whirlwind

	# Boosted effects (increased movement speed, range, etc.)
	if IsBoosted:
		MoveSpeed *= 1.5  # Increase movement speed
		WhirlwindDamage *= 1.5  # Increase damage for boosted whirlwind
		KnockbackMultiplier = BoostedKnockbackMultiplier  # Increase knockback for boosted ability
		IsBoosted = false
		WasBoosted = true

	# Start timer for whirlwind duration
	var whirlwind_duration_timer = Timer.new()
	
	# Start a timer for the whirlwind duration
	var whirlwind_timer = Timer.new()
	whirlwind_timer.wait_time = WhirlwindSlashDuration
	whirlwind_timer.one_shot = true
	whirlwind_timer.timeout.connect(_on_whirlwind_end)
	add_child(whirlwind_timer)
	whirlwind_timer.start()

	# Start applying damage periodically
	_start_whirlwind_damage()

func Ability4Boosted():
	IsBoosted = true
	AttackSpeedDelay *= 0.5
	MoveSpeed *= 1.5
	JumpStrength *= 1.2
	AttackBuffTimer.start()

#endregion
