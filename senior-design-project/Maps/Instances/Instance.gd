class_name Instance extends Node2D

@onready var EnemyHolder : Node2D = $"Preset Enemies"
@onready var PlayerRef : CharacterBaseScene = get_tree().get_first_node_in_group("Player")
var Done : bool = false #done with the fight but not exited, likely looking at item, spawns still disabled and camera still set
var Started : bool = false #started the fight
var Compleated : bool = false #turns off all instance functionality after player leaves the instance
@export var CameraMove : bool = true
'''
Instances need to1
1. Move Camera to center of stage, and shut the door
2. Disable or kill all outside enemies
3. Enable the spawns
4. Wait until all spawns die
5. Open the door and drop the loot
6. Maybe pause spawns until the player leaves the area?

1. Player enters, if not compleated, EntityEntered setsup everything, sets Started flag
2. Player kills everything, which triggers _Checkdone, checkdone sets Done 
3. Player Leaves area, if done, sets compleated flag, resets camera and starts spawns again
'''




func EntityEntered(body):
	if not Compleated:
		if body is CharacterBaseScene and not Started:
			Started = true
			_Startup()

func _Startup(): #and spawns
	#TODO pause spawning behavior
	SignalBus.EnemyDied.connect(_CheckDone)
	_CloseDoor()
	
	var in_area = $EntityDetection.get_overlapping_bodies()
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy.can_process():
			if enemy not in in_area: #if the enemy is outside of the instance, we destroy it
				enemy.queue_free()
	
	await _SetCamera() #set the camera, and wait for it

	_SpawnEnemies() #after setting camera, spawn enemies
	
func _CloseDoor():
	$Doors.enabled = true	

func _SetCamera():
	'''Moving the camera'''
	print("setting camera")
	var camera : Camera2D = get_tree().get_first_node_in_group("Camera")
	
	camera.position_smoothing_enabled = false
	await get_tree().create_timer(.05).timeout #this smooths out the transition
	
	var cameraoriginalposition = camera.global_position
	camera.get_parent().remove_child(camera)
	add_child(camera)
	camera.global_position = cameraoriginalposition
	var tw : Tween = get_tree().create_tween()
	tw.tween_property(camera, "global_position", $CameraPosition.global_position, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tw.finished	
	get_tree().get_first_node_in_group("GamePlayUI").position.y = -260
	get_tree().get_first_node_in_group("GamePlayUI").modulate.a = .5
	
func _SpawnEnemies():
	'''then setting up enemies'''
	$"Preset Enemies".visible = true
	$"Preset Enemies".process_mode = Node.PROCESS_MODE_INHERIT #this should turn on all the preset enemies
	for child in $"Preset Enemies".get_children():
		if child.has_method("Activate"):
			child.Activate()
	


'''After Done'''


func _CheckDone(enemydied): #this needs an arg to match the signal, it's not even necessary
	print("hey I saw something die")
	await get_tree().create_timer(1).timeout
	if EnemyHolder.get_child_count() == 0:
		print("hey I think we're done")
		_Complete()
	print("hey we're not done")

func EntityLeaving(body):
	if Compleated and body is CharacterBaseScene:
		await _ResetCamera()
		_EnableSpawn()

func _EnableSpawn():
	pass
	#TODO Enable spawns
	
func _ResetCamera():
	var camera : Camera2D = get_tree().get_first_node_in_group("Camera")
	var cameraoriginalposition = camera.global_position
	camera.get_parent().remove_child(camera)
	PlayerRef.add_child(camera)
	camera.global_position = cameraoriginalposition
	var camerafinalpos = get_tree().get_first_node_in_group("PlayerCameraPosition")
	var tw : Tween = get_tree().create_tween()
	tw.tween_property(camera, "position", camerafinalpos.position, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tw.finished	
	camera.position_smoothing_enabled = true
	get_tree().get_first_node_in_group("GamePlayUI").position.y = 0
	get_tree().get_first_node_in_group("GamePlayUI").modulate.a = 1
	
func _OpenDoor():
	$Doors.enabled = false
	
func _SpawnLoot():
	pass #TODO spawn the loot
		
func _Complete():
	SignalBus.EnemyDied.disconnect(_CheckDone) #disconnect signal, no longer needed
	Compleated = true
	_SpawnLoot()
	_OpenDoor()
	#enable spawn when leaving the area
	
