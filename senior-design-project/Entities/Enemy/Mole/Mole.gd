extends EnemyBaseScene

var AI_Timer : float = 0
@export var AI_Phase : int = 0: #default is 1
	get:
		return AI_Phase
	set(value):
		AI_Phase = value
		AI_Timer = 0

@export var IdleTime : float = 1
@export var DigTime : float = .75
@export var AttackTime : float = 1
@export var StunTime : float = .33
@onready var Proj : PackedScene = preload("res://Entities/Enemy/Mole/MoleProjectile.tscn")
@onready var AnimPlayer : AnimationPlayer = $AnimationPlayer
'''
AI is simple - 
Idle (start) -> dig animation-> Look for place to teleport near player and teleport there with digup animation -> 
idle (aggro) -> if player in LOS, throw dirt -> idle (start)

Can be inturrupted at any point, after the stun, go straight into idle (aggro)

Idle (start) - 1
Digging down - 2
Teleport (n/a, instant, called by digging done)
Digging up - 3
Idle (aggro) - 4
Throwing animation - 5 
Throw dirt (n/a, instant, called by throwing animation done)
Stunned - 6
'''

func Activate():
	if AI_Phase == 0:
		print("MOLE ACTIVATION")
		AI_Phase = 1

var FacingRight : bool = true
@onready var Sprite : AnimatedSprite2D = $Sprite2D
@onready var ProjSpawn : Marker2D = $Sprite2D/Marker2D
func _AI(delta : float):#Override This
	AI_Timer += delta
	$"Delete this - testing only".text = str(AI_Phase)
	
	if PlayerRef.global_position.x > global_position.x:
		FacingRight = true
		Sprite.flip_h = false
		ProjSpawn.position.x = 27
	else:
		FacingRight = false
		Sprite.flip_h = true
		ProjSpawn.position.x = -27
		
	match AI_Phase:
		0:
			pass
		1: #idle start
			AnimPlayer.play("Idle")
			if AI_Timer >= IdleTime:
				AI_Phase = 2
				Dig()
		2: #digging down
			pass
			#everything set by animation
		3: #teleported, digging up animation
			pass
		4: #idle aggro
			AnimPlayer.play("Idle")
			if AI_Timer >= IdleTime:
				AI_Phase = 5
		5: #throw animation
			if AI_Timer >= AttackTime: #it may be more appropriate to tie this into the attack animation itself instead and await done
				Attack()
				#AI_Phase = 1
		6: #stunned
			pass
			#if AI_Timer >= StunTime:
				#AI_Phase = 4
	
func _physics_process(delta): #Override this
	_AI(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	
func Dig():
	AnimPlayer.play("DigDown")
	await AnimPlayer.animation_finished
	AI_Phase = 3
	var dist : int = 12
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
								AnimPlayer.play_backwards("DigUp_Play_Backwards")
								return
	
	#if rng checks all fail, we warp to last viable location
	var pos = lastmap.map_to_local(lastviableplace)
	global_position = lastmap.to_global(pos)
	AnimPlayer.play_backwards("DigUp_Play_Backwards")

func Attack():
	AnimPlayer.play("Windup and Throw")

func SuccessfulAttack():
	var Proj_Instance = Proj.instantiate()
	AI_Phase = 1
	if Proj_Instance is MoleProjectile:
		Proj_Instance.global_position = ProjSpawn.global_position
		Proj_Instance.Normalized_Direction = ProjSpawn.global_position.direction_to(PlayerRef.global_position+Vector2(0,-15))
		get_parent().add_child(Proj_Instance)

@onready var FlashPlayer : AnimationPlayer = $FlashPlayer
func _Got_Hit(Data : AttackData): #Override This
	FlashPlayer.play("Flash")
	if AI_Phase == 2 or AI_Phase == 6:
		pass
	else:
		print("got stunned")
		AI_Phase = 6
		AnimPlayer.play("Stunned")
		await AnimPlayer.animation_finished
		AI_Phase = 2
		Dig()
	TakeDamage(Data.Damage)
	ApplySpecialEffects(Data)

func Die():
	$Hitbox/CollisionShape2D.set_deferred("disabled",true)
	$Sprite2D.material = null
	velocity = Vector2.ZERO
	AI_Phase = 9
	var tw : Tween = get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0, 3)
	await tw.finished
	queue_free()
