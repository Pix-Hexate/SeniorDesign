extends EnemyBaseScene

var AI_Timer : float = 0
@export var AI_Phase : int = 0: #default is 1
	get:
		return AI_Phase
	set(value):
		AI_Phase = value
		AI_Timer = 0

@onready var _Hurtbox : Hurtbox = $WarningBeam/Beam/Hurtbox
@export var Damage : float = 20
@export var Max_Rotation_Rate : float = TAU/9
@onready var WarningBeam : Sprite2D = $WarningBeam
@onready var Beam : Sprite2D = $WarningBeam/Beam
@onready var AnimPlayer : AnimationPlayer = $AnimationPlayer
func _ready():
	var AtkData : AttackData = AttackData.new()
	AtkData.Damage = Damage
	_Hurtbox.StoredAttackData = AtkData


var IdleTime : float = 5
var TrackingTime : float = 2.5
var LockTime : float = 1
var TeleportTime : float = 1
var Target_Angle : float
var Angle_Diff : float

func _AI(delta : float):
	match AI_Phase:
		1: #idle
			WarningBeam.visible = false
			AI_Timer += delta
			if AI_Timer >= IdleTime:
				#AI_Phase = 2 #done by animation
				WarningBeam.rotation += wrapf(WarningBeam.get_angle_to(PlayerRef.global_position+Vector2(0,-25)) - rotation, -PI, PI)
				AnimPlayer.play("RaiseStaff")
		2: #attack tracking
			WarningBeam.visible = true
			Target_Angle = WarningBeam.get_angle_to(PlayerRef.global_position+Vector2(0,-25))
			Angle_Diff = wrapf(Target_Angle - rotation, -PI, PI)
			Angle_Diff = clamp(Angle_Diff, -Max_Rotation_Rate*delta, Max_Rotation_Rate*delta)
			WarningBeam.rotation += Angle_Diff
			AI_Timer += delta
			if AI_Timer >= TrackingTime:
				AI_Phase = 3
		3: #attack locked
			AI_Timer += delta
			if AI_Timer >= LockTime:
				Attack()
				AI_Phase = 4
		4: #attacking, waiting for animation
			pass
		5: #teleport
			pass
		6: #stunned
			pass

func Attack():
	AnimPlayer.play("Attack")
	await AnimPlayer.animation_finished
	if AI_Phase == 4:
		AI_Phase = 5
		Teleport()
	else: #this means we got hitstunned, and the hitstun will take over ai change
		pass 
	
func Teleport():
	AnimPlayer.play("TeleportOut")
	await get_tree().create_timer(4).timeout
	
	if AI_Phase == 5:	#if not at 5, that means we got inturrupted and we dont teleport
		AI_Phase = 1
		var dist : int = 20 #base 20
		var maps = get_tree().get_nodes_in_group("Map")
		var lastviableplace : Vector2i = Vector2i(0,0) 
		var lastmap : TileMapLayer = null
		for map in maps:
			if map is TileMapLayer:	 #we scan a dist-sized square around the player
				lastmap = map
				var player_map_pos : Vector2 = map.local_to_map(PlayerRef.global_position)
				for x in range(player_map_pos.x - dist, player_map_pos.x + dist):
					for y in range(player_map_pos.y - dist, player_map_pos.y + dist):
						var data = map.get_cell_tile_data(Vector2i(x, y)) #and check every tile
						if data: #if there is something on that tile
							data = map.get_cell_tile_data(Vector2i(x, y-1)) 
							if not data: #we check the tile above it, and if its empty, chance to teleport based on dist
								lastviableplace = Vector2i(x,y-1)
								var distance : float = player_map_pos.distance_to(lastviableplace)
								var chance : float = (distance / dist) / 10
								if randf() < chance:
									var pos = map.map_to_local(lastviableplace)
									global_position = map.to_global(pos)
									AnimPlayer.play_backwards("TeleportOut")
									return

		#if rng checks all fail, we warp to last viable location
		var pos = lastmap.map_to_local(lastviableplace)
		global_position = lastmap.to_global(pos)
		AnimPlayer.play_backwards("TeleportOut")

	

func _physics_process(delta): #Override this
	_AI(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

var StunTime : float = .5
@onready var FlashPlayer : AnimationPlayer = $FlashPlayer
func _Got_Hit(Data : AttackData): #Override This
	if AI_Phase == 5 or AI_Phase == 6:
		AnimPlayer.play("Stunned")
	FlashPlayer.play("Flash")
	if (AI_Phase == 2) or (AI_Phase == 3):
		WarningBeam.visible = false
	PlayerAggroTimer.stop()
	AI_Phase = 6
	velocity.x = 0
	StunTimer.start(StunTime)
	TakeDamage(Data.Damage)
	ApplySpecialEffects(Data)

func Die():
	$AnimatedSprite2D.material = null
	$Hitbox/CollisionShape2D.set_deferred("disabled",true)
	velocity = Vector2.ZERO
	AI_Phase = 9
	WarningBeam.visible = false
	$WarningBeam/Beam/Hurtbox/CollisionShape2D.disabled = true
	var tw : Tween = get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0, 3)
	await tw.finished
	queue_free()
'''
Mage

Idle, then checks if player is within proper range (mid range), if so, prep spell animation, then lock the direction, and then fire
If player is too close or far, teleport to a proper range and go to idle.
Can get hitstunned at any point


1. Idle
2. Spell Prep 1 (tracking)
3. Spell prep 2 (locked)
4. Spell fire
5. Teleport animation
6. Hitstun

'''


func _on_stun_timer_timeout():
	if AI_Phase == 6:
		AI_Phase = 1
		Teleport()

func Activate():
	if AI_Phase == 0:
		AI_Phase = 1
