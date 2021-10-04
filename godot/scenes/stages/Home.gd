extends MarginContainer

onready var level_map = $LevelMap


func _ready():
	# No pause for the title scene
	get_tree().paused = false
	
	#var main_node = get_node_or_null("/root/Main")
	#if main_node:
	#	main_node.bgm_player.start_bgm("res://assets/music/Dream Static by symphony.mp3")
	
	# Translation.
	_when_locale_changed()
	Global.connect("locale_changed", self, "_when_locale_changed")


func _when_progress_downloaded():
	# Theme
	#$Bg.texture = load("res://assets/ui/%s/bg_1.png" % Global.theme)
	
	# Set up level buttons
	level_map.update_level_buttons()


func _on_LevelsPanelC_level_pressed(level_name):
	# Retrieve level info
	var level_config = Global.level_db[level_name]
	Global.current_level = level_name
	
	var target_score = level_config["score"]

	# Change scene with transition
	var main_node = get_node_or_null("/root/Main")
	if main_node:
		main_node.loading_panel.load_scene("res://scenes/levels/Level0.tscn")
		main_node.bgm_player.stop_bgm()


func _when_locale_changed():
	pass
	#terminal_btn.text = tr("TERMINAL")
	#settings_btn.text = tr("SETTINGS")
	#watch_ads_btn.text = tr("WATCH_ADS")


func _on_About_pressed():
	$AboutPage.show()


func _on_Exit_pressed():
	get_tree().quit()
