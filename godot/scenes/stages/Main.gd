extends Node


onready var running_node = $HBoxContainer/ViewportContainer/Viewport/Running
onready var loading_panel = $HBoxContainer/ViewportContainer/Viewport/CanvasLayer/LoadingPanel
onready var bgm_player = $BgmPlayer
onready var debug = $HBoxContainer/ViewportContainer/Viewport/CanvasLayer/Debug


func _ready():
	Global.main = self
	bgm_player.start_bgm("res://assets/music/Talking-Cute-Chiptune-by-Pro-Sensory.ogg")


func _process(_delta):
	debug.get_node("FpsLabel").text = "FPS %d" % round(Engine.get_frames_per_second())
	debug.get_node("General").text = str(Global.player_input_enabled)


func _on_TitleStage_start_pressed():
	change_stage_by_path("res://scenes/stages/Home.tscn")


func change_stage_by_path(scene_path):
	loading_panel.load_scene(scene_path)


func add_stage(child):
	running_node.add_child(child)


func clear_stages():
	for child in running_node.get_children():
		child.queue_free()


func _on_ViewportContainer_resized():
	$HBoxContainer/ViewportContainer/Viewport.size = $HBoxContainer/ViewportContainer.rect_size
