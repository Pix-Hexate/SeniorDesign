class_name BetterButton extends Button
var LeftPos : Vector2
var RightPos : Vector2 
@onready var LeftLabel : Label = $LeftArrow
@onready var RightLabel : Label = $RightArrow

# Called when the node enters the scene tree for the first time.
func _ready():
	LeftPos = LeftLabel.position
	RightPos = Vector2(get_minimum_size().x+5, 0)

func TextChanged():
	LeftPos = LeftLabel.position
	RightPos = Vector2(get_minimum_size().x+5, 0)

func _on_mouse_entered():
	LeftLabel.position = LeftPos + Vector2(-15,0)
	RightLabel.position = RightPos + Vector2(15,0)
	LeftLabel.visible = true
	RightLabel.visible = true
	var tw : Tween = get_tree().create_tween()
	var tw2 : Tween = get_tree().create_tween()
	
	tw.tween_property(LeftLabel, "position", LeftPos, .5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw2.tween_property(RightLabel, "position", RightPos, .5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	AudioManager.QueueRandomizedSound("ButtonHover")


func _on_mouse_exited():
	LeftLabel.visible = false
	RightLabel.visible = false
