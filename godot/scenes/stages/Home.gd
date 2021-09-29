extends MarginContainer

onready var coin_label = $MarginC/Control/StatusVBoxC/Coin
onready var level_map = $LevelMap
onready var terminal_page = $TerminalPanelC
onready var start_panel = $StartPanel
onready var tween = $Tween

onready var terminal_btn = $MarginC/Control/PageVBoxC/Terminal
onready var settings_btn = $MarginC/Control/PageVBoxC/Settings
onready var watch_ads_btn = $MarginC/Control/EventVBoxC/Ads

onready var map_progress = $MarginC/Control/TextureProgress
onready var map_path_follow = $MarginC/Control/TextureProgress/Path2D/PathFollow2D


func _ready():
	# No pause for the title scene
	get_tree().paused = false
	
	var main_node = get_node_or_null("/root/Main")
	if main_node:
		main_node.bgm_player.start_bgm("res://assets/music/Dream Static by symphony.mp3")
	
	_update_ui()
	
	# Translation.
	_when_locale_changed()
	Global.connect("locale_changed", self, "_when_locale_changed")


func hide_ui_elements():
	$MarginC/Control.modulate = Color.transparent
	level_map.hide_levels()


func show_ui_elements():
	_update_ui()
	
	tween.interpolate_property($MarginC/Control, "modulate", Color.transparent, Color.white, 0.2)
	level_map.show_levels()
	tween.start()
	yield(tween, "tween_all_completed")


func _process(delta):
	#if not $MarginC/Control/EventVBoxC/AdReward/Timer.is_stopped():
	#	var time_left_for_online_reward = int(round($MarginC/Control/EventVBoxC/AdReward/Timer.time_left))
	#	$MarginC/Control/EventVBoxC/AdReward/Label.text = '%d:%d' % [int(time_left_for_online_reward / 60), time_left_for_online_reward % 60]
	
	# Scroll
	map_path_follow.unit_offset = level_map.scroll_ratio
	map_progress.value = level_map.progress_ratio * 100
	

func _update_ui():
	# Update coin number
	coin_label.text = str(Global.get_coin())


func _when_progress_downloaded():
	# Theme
	#$Bg.texture = load("res://assets/ui/%s/bg_1.png" % Global.theme)
	
	# Set up level buttons
	level_map.update_level_buttons()


func _on_Terminal_pressed():
	terminal_page.show_elegantly()


func _on_LevelsPanelC_level_pressed(level_name):
	# Retrieve level info
	var level_config = Global.level_db[level_name]
	Global.current_level = level_name
	
	var target_score = level_config["score"]
	
	# Config start panel
	start_panel.prepare(level_name, target_score)
	
	# Show start panel
	start_panel.show_with_transition()


func _on_Settings_pressed():
	$SettingsPage.show_elegantly()


func _on_Ads_pressed():
	$MarginC/Control/EventVBoxC/Ads.disabled = true
	get_node("/root/Main").admob.show_rewarded_video()
	$MarginC/Control/EventVBoxC/Ads/AdsTimer.start()


func _on_LevelMap_item_shop_pressed():
	$ItemShopPage.show_elegantly()


func _when_locale_changed():
	pass
	#terminal_btn.text = tr("TERMINAL")
	#settings_btn.text = tr("SETTINGS")
	#watch_ads_btn.text = tr("WATCH_ADS")
