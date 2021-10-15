extends Node2D

var level_name = "Train"
var start_pos : float
var end_pos : float

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = $FixedBack/StartPoint.position.x
	end_pos = $FixedBack/EndPoint.position.x


func _process(delta):
	var player_pos = $Dynamic/Player.position.x
	
	Global.hud.level_progress = (player_pos - start_pos) / (end_pos - start_pos)
