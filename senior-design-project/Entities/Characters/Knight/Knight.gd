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
@export var AttackKnockbackBase: float = 300.0
@export var CurrentAttackKnockback : float = 300.0
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
	"AbilityFour": 20.0
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
@onready var attack_hitbox = $AttackHitbox  # Reference the Area2D

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
	
	# Connect attack hitbox detection
	attack_hitbox.area_entered.connect(_on_attack_hitbox_entered)

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
	regen_timer += delta
	if regen_timer >= 1.0:  # Apply health regen every second
		regen_timer = 0
		Heal(HealthRegen)
		
	if is_whirlwind_active:
		# Rotate the player character
		rotation += WhirlwindSpeed * delta

		# Move the player in the direction they're facing
		var direction = Vector2(cos(rotation), sin(rotation))
		global_position += direction * WhirlwindSpeed * delta

		# Hit detection with enemies in the range
		_check_for_hits_in_whirlwind()

func Heal(amount: float):
	CurrentHP = min(CurrentHP + amount, MaxHP)

func _Got_Hit(Data: AttackData):
	if IsInvulnerable:
		print("Attack Blocked!")
		# If boosted, reflect damage
		if IsBoosted:
			_reflect_damage(Data)
		return		
	var damage = Data.damage
	damage = max(damage - Armor, 1)  # Reduce damage by armor, minimum 1
	TakeDamage(damage)

func TakeDamage(amount: int):		
	CurrentHP -= amount
	print("Took " + str(amount) + " damage")	
	if CurrentHP <= 0:
		Die()

func Die():
	print("Knight has fallen!")
	queue_free()

# Handles boost expiration
func _on_boost_expired():
	print("Boost expired!")
	AttackSpeedDelay *= 1.5
	MoveSpeed /= 1.5
	IsBoosted = false
	
func _on_attack_hitbox_entered(area):
	if area.is_in_group("Enemies"):
		var enemy = area.get_parent()
		if enemy.has_method("TakeDamage"):
			# Determine if it's a critical hit
			var is_crit = randf() < CritChance
			var final_damage = AttackDamage * (CritDamage if is_crit else 1)		
			# Apply damage to the enemy
			enemy.TakeDamage(AttackDamage)
			_apply_knockback(enemy)

func _apply_knockback(enemy):
	var direction = (enemy.global_position - global_position).normalized()
	enemy.apply_impulse(direction * CurrentAttackKnockback)

func _pull_enemy_towards_player(enemy):
	var direction = (global_position - enemy.global_position).normalized()
	var pull_force = 500.0  # Adjust as needed
	enemy.apply_impulse(direction * pull_force)
	
func _reflect_damage(Data: AttackData):
	print("Reflecting damage!")

	# Create a blast hitbox
	var blast = Area2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 50  # Adjust as needed
	blast.add_child(shape)

	# Position blast in front of player
	blast.global_position = global_position + Vector2(50, 0).rotated(rotation)  # Adjust offset

	# Add blast to scene
	get_parent().add_child(blast)

	# Damage enemies in blast radius
	for area in blast.get_overlapping_areas():
		if area.is_in_group("Enemies"):
			var enemy = area.get_parent()
			if enemy.has_method("TakeDamage"):
				enemy.TakeDamage(Data.damage)  # Reflect full damage back

	# Remove blast after a short delay
	await get_tree().create_timer(0.2).timeout
	blast.queue_free()
	
	# Stop whirlwind after its duration
func _on_whirlwind_end():
	is_whirlwind_active = false
	set_process(false)
	if !WasBoosted:
		MoveSpeed /= 1.5  # Increase movement speed
		WhirlwindDamage /= 1.5
		WasBoosted = false
	# Reset knockback multiplier
	KnockbackMultiplier = 1.0
	CurrentAttackKnockback = AttackKnockbackBase
	AbilityCooldownTimers["AbilityThree"].start()
	print("Whirlwind Slash ended!")
		
func _start_whirlwind_movement():
	# Logic to rotate the player and move forward while spinning
	var rotation_speed: float = 5.0  # Speed of rotation
	# Add a process to rotate and move while the ability is active
	set_process(true)

func _check_for_hits_in_whirlwind():
	# Check for collision with enemies during the whirlwind
	for enemy in attack_hitbox.get_overlapping_areas():
		if enemy.is_in_group("Enemies"):
			# Apply damage and knockback
			enemy.TakeDamage(WhirlwindDamage, false)  # No crits during whirlwind
			_apply_Whirlwind_knockback(enemy)
			
	
func _apply_Whirlwind_knockback(enemy):
	# Calculate direction of knockback
	var direction = (enemy.global_position - global_position).normalized()
	CurrentAttackKnockback *= KnockbackMultiplier
	enemy.apply_impulse(direction * CurrentAttackKnockback)

func BasicAttack():
	print("Basic Attack: Slashing forward!")
	# Enable hitbox temporarily
	attack_hitbox.monitoring = true
	# Trigger attack animation
	AnimPlayer.play("BasicAttack")
	for area in attack_hitbox.get_overlapping_areas():
		if area.is_in_group("Enemies"):
			var enemy = area.get_parent()
			if enemy.has_method("TakeDamage"):
				enemy.TakeDamage(AttackDamage)
				
	# Start attack cooldown
	AbilityCooldownTimers["BasicAttack"].start()
	
	# Wait for attack delay, then disable hitbox
	await get_tree().create_timer(0.1).timeout
	attack_hitbox.monitoring = false  # Disable hitbox after attack
	
func Ability1Stab():
	print("Ability 1: Stab!")  
	# Enable hitbox for attack detection
	attack_hitbox.monitoring = true
	# Play stab animation
	AnimPlayer.play("AbilityOne")
	# Start cooldown
	AbilityCooldownTimers["AbilityOne"].start()
	# Wait for a brief moment to allow the hitbox to detect enemies
	await get_tree().create_timer(0.2).timeout  # Adjust timing as needed
	if IsBoosted:
		attack_hitbox.scale *= 1.5  # Increase stab range
		
	CurrentAttackKnockback == 0 
	# Check for enemies in range
	for area in attack_hitbox.get_overlapping_areas():
		if area.is_in_group("Enemies"):
			var enemy = area.get_parent()
			if enemy.has_method("TakeDamage"):
				enemy.TakeDamage(AttackDamage * 1.5)
				if IsBoosted:
					attack_hitbox.scale /= 1.5
					_pull_enemy_towards_player(enemy)
					IsBoosted = false

	# Disable hitbox after the attack
	attack_hitbox.monitoring = false
	CurrentAttackKnockback = AttackKnockbackBase

func Ability2Block():
	print("Ability 2: Blocking!")
	# Play block animation
	AnimPlayer.play("AbilityTwo")
	# Set invulnerability flag
	IsInvulnerable = true
	# Start cooldown
	AbilityCooldownTimers["AbilityTwo"].start()
	# Wait for a short duration of invulnerability
	await get_tree().create_timer(0.3).timeout
	IsBoosted = false;
	# Remove invulnerability
	IsInvulnerable = false
				
func Ability3WhilrwindSlash():
	if Playing_Action or is_whirlwind_active:
		return  # Prevent spamming the ability if already active

	is_whirlwind_active = true
	original_attack_speed = AttackSpeedDelay  # Store original attack speed

	# Adjust attack speed (decreased cooldown for basic attack while spinning)
	AttackSpeedDelay /= 0.5  # Faster attacks during whirlwind

	# Trigger animation
	AnimPlayer.play("AbilityThree")
	
	# Boosted effects (increased movement speed, range, etc.)
	if IsBoosted:
		MoveSpeed *= 1.5  # Increase movement speed
		WhirlwindDamage *= 1.5  # Increase damage for boosted whirlwind
		KnockbackMultiplier = BoostedKnockbackMultiplier  # Increase knockback for boosted ability
		IsBoosted = false

	# Start timer for whirlwind duration
	var whirlwind_duration_timer = Timer.new()
	
	# Allow movement during the whirlwind
	_start_whirlwind_movement()
	whirlwind_duration_timer.wait_time = WhirlwindSlashDuration
	whirlwind_duration_timer.one_shot = true
	whirlwind_duration_timer.timeout.connect(_on_whirlwind_end)
	add_child(whirlwind_duration_timer)
	whirlwind_duration_timer.start()

func Ability4Boosted():
	IsBoosted = true
	AttackSpeedDelay /= 1.5
	MoveSpeed *= 1.5
	AttackBuffTimer.start()
	AbilityCooldownTimers["AbilityFour"].start()
