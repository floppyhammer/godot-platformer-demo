extends Node2D

var level_name = "The Begining"


func _ready():
	if Global.main:
		Global.main.bgm_player.start_bgm("res://assets/music/Jump and Run (8-bit) by bart.ogg")
