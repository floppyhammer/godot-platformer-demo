extends Node2D


var start_point : Vector2

onready var player = $Dynamic/Player


func _ready():
	start_point = $FixedBack/StartPoint.get_global_position()
	
	if Global.main:
		Global.main.bgm_player.start_bgm("res://assets/music/Jump and Run (8-bit) by bart.ogg")
	
	Global.current_level = self


func _on_Player_when_respawned():
	player.position = start_point


func add_object(object):
	$Dynamic.add_child(object)
