extends Node2D

var level_name = "The Begining"

var start_point : Vector2

onready var player = $Dynamic/Player


func _ready():
	start_point = $FixedBack/StartPoint.get_global_position()
	
	if Global.main:
		Global.main.bgm_player.start_bgm("res://assets/music/Jump and Run (8-bit) by bart.ogg")


func _on_Player_when_respawned():
	player.position = start_point
