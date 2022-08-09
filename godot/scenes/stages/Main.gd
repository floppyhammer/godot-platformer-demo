extends Node


onready var loading_panel = $CanvasLayer/LoadingPanel
onready var bgm_player = $BgmPlayer
onready var debug = $CanvasLayer/Debug


func _ready():
	Global.main = self
	bgm_player.start_bgm("res://assets/music/Dream Static by symphony.mp3")


func _process(_delta):
	debug.get_node("FpsLabel").text = "FPS %d" % round(Engine.get_frames_per_second())


func _on_TitleStage_start_pressed():
	loading_panel.load_scene("res://scenes/stages/Home.tscn")
