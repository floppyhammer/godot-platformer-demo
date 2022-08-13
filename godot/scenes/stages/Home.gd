extends MarginContainer

onready var level_map = $WorldMapPanel


func _ready():
	# No pause for the home scene.
	get_tree().paused = false
	
	# Translation.
	_when_locale_changed()
	Global.connect("locale_changed", self, "_when_locale_changed")


func _when_progress_downloaded():
	# Set up level buttons
	level_map.update_level_buttons()


func _on_LevelsPanelC_level_pressed(level_name):
	# Retrieve level info
	var level_config = Global.level_db[level_name]
	Global.current_level = level_name
	
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


func _on_Exit_pressed():
	get_tree().quit()
