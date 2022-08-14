extends Node2D

var level_name = "Level 0"


func _ready():
	if Global.main:
		Global.main.bgm_player.start_bgm("res://assets/music/the-internationale-8-bit.ogg")
