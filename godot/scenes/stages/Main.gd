extends Node

onready var admob = $AdMob
onready var loading_panel = $CanvasLayer/LoadingPanel
onready var bgm_player = $BGMPlayer


func _ready():
	bgm_player.start_bgm("res://assets/music/Caketown-by-Matthew-Pablo.ogg")


func _process(delta):
	$CanvasLayer/Debug/FPSLabel.text = "FPS %d" % round(Engine.get_frames_per_second())


func loadAds() -> void:
	admob.load_banner()
	admob.move_banner(false)
	
	admob.load_interstitial()
	admob.load_rewarded_video()


func _on_AdMob_rewarded_video_closed():
	admob.load_rewarded_video()


func _on_AdMob_banner_loaded():
	# Leave margin for the ads banner.
	var ads_size = admob.get_banner_dimension()
	#margin_bottom = -ads_size.y


func _on_TitleStage_start_pressed():
	loading_panel.load_scene("res://scenes/stages/Home.tscn")
	bgm_player.stop_bgm()
	loadAds()
