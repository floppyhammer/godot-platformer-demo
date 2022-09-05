extends Node2D


var start_point : Vector2

onready var player = $Dynamic/Player


func _ready():
	if Global.main:
		Global.main.bgm_player.start_bgm("res://assets/music/the-internationale-8-bit.ogg")

	start_point = $FixedBack/StartPoint.get_global_position()
