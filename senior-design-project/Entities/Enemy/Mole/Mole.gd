extends EnemyBaseScene

var AI_Timer : float = 0
var AI_Phase : int = 1:
	get:
		return AI_Phase
	set(value):
		AI_Phase = value
		AI_Timer = 0

@export var IdleTime : float = 2
@export var DigTime : float = 1.5
@export var AttackTime : float = 1
@export var StunTime : float = .33
@onready var Proj : PackedScene = preload("res://Entities/Enemy/Mole/MoleProjectile.tscn")
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

func _AI(delta : float):#Override This
	AI_Timer += delta
	$"Delete this - testing only".text = str(AI_Phase)
	match AI_Phase:
		1: #idle start
			if AI_Timer >= IdleTime:
				AI_Phase = 2
		2: #digging down
			if AI_Timer >= DigTime:
				Dig()
				AI_Phase = 3
		3: #digging up #it may be more appropriate to tie this into the digup animation itself instead and await done
			if AI_Timer >= DigTime:
				AI_Phase = 4
		4: #idle aggro
			if AI_Timer >= IdleTime:
				AI_Phase = 5
		5: #throw animation
			if AI_Timer >= AttackTime: #it may be more appropriate to tie this into the attack animation itself instead and await done
				Attack()
				AI_Phase = 1
		6: #stunned
			if AI_Timer >= StunTime:
				AI_Phase = 4
	
func _physics_process(delta): #Override this
	_AI(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	
func Dig():
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
								return
	
	#if rng checks all fail, we warp to last viable location
	var pos = lastmap.map_to_local(lastviableplace)
	global_position = lastmap.to_global(pos)

func Attack():
	var Proj_Instance = Proj.instantiate()
	if Proj_Instance is MoleProjectile:
		Proj_Instance.global_position = global_position + Vector2(0,-10)
		Proj_Instance.Normalized_Direction = global_position.direction_to(PlayerRef.global_position+Vector2(0,-15))
		get_parent().add_child(Proj_Instance)

func Got_Hit(Data : AttackData): #Override This
	AI_Phase = 3
	StunTimer.start()
	#TODO flash white
