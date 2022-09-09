extends Node2D


var start_point : Vector2

onready var player = $Dynamic/Player


func _ready():
	if Global.main:
		Global.main.bgm_player.start_bgm("res://assets/music/the-internationale-8-bit.ogg")

	start_point = $FixedBack/StartPoint.get_global_position()

	Global.current_level = self


func _on_Player_when_respawned():
	player.position = start_point


func add_object(object):
	$Dynamic.add_child(object)
