class_name GameplayUI extends Control


@onready var BoostHider = $Boost/Hider
@onready var BoostCooldown : Label = $Boost/Hider/CD
var BoostCDNumber : float = 0

@onready var StabHider = $Stab/Hider
@onready var StabCooldown : Label = $Stab/Hider/CD
var StabCDNumber : float = 0

@onready var BlockHider = $Block/Hider
@onready var BlockCooldown : Label = $Block/Hider/CD
var BlockCDNumber : float = 0

func _physics_process(delta):
	BoostCDNumber -= delta
	StabCDNumber -= delta
	BlockCDNumber -= delta
	
	if BoostCDNumber <= 0:
		BoostHider.visible = false
	else:
		BoostCooldown.text = str(snapped(BoostCDNumber, 1))

	if StabCDNumber <= 0:
		StabHider.visible = false
	else:
		StabCooldown.text = str(snapped(StabCDNumber, 1))
		
	if BlockCDNumber <= 0:
		BlockHider.visible = false
	else:
		BlockCooldown.text = str(snapped(BlockCDNumber, 1))
		
		
func SetBlock(val : float):
	BlockCDNumber = val
	BlockHider.visible = true
	
func SetStab(val:float):
	StabCDNumber = val
	StabHider.visible = true
	
func SetBoost(val:float):
	BoostCDNumber = val
	BoostHider.visible = true
