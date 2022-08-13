extends Control

var languages_list = ["zh", "en"]
var level_progress = 0

var is_menu_shown = false

onready var menu_btn = $MenuAndStatus/VBox/StatusBar/Menu
onready var menu_panel = $MenuAndStatus/VBox/MenuPanel
onready var result_panel = $ResultPanel
onready var tween = $Tween
onready var lang_btn = $MenuAndStatus/VBox/MenuPanel/Options/Language
onready var dialog = $DialogPanel
onready var notification_spawner = $NotificationSpawner
onready var shop_panel = $ShopPanel
onready var joystick = $Joystick


func _ready():
	Logger.add_module("HUD")
	
	show()
	result_panel.hide()
	Global.hud = self
	_hide_menu()
	result_panel.hide()
	Global.connect("locale_changed", self, "_when_locale_changed")
	
	#var level_name = get_parent().get_parent().get("level_name")
	#if level_name is String:
	#	$MapLabel.text = level_name


func add_notification(p_text : String):
	notification_spawner.add_notification(p_text)


func show_result_panel():
	# Hide menu panel.
	menu_panel.hide()
	result_panel.show_when_level_is_clear("Level 0", 10, 10)


func _show_menu():
	$BlurShader.change_blur_amount(2, 0.5)
	
	joystick.hide()
	
	# Show menu panel with transition.
	menu_panel.show()
	tween.remove_all()
	tween.interpolate_property(menu_panel, "modulate", Color.transparent, Color.white, 0.2)
	tween.start()
	
	get_tree().paused = true


func _hide_menu():
	$BlurShader.change_blur_amount(0, 0.5)
	
	joystick.show()
	
	# Hide menu panel with transition.
	tween.remove_all()
	tween.interpolate_property(menu_panel, "modulate", Color.white, Color.transparent, 0.2)
	tween.start()
	
	get_tree().paused = false


func show_shop_panel():
	$BlurShader.change_blur_amount(2, 0.5)
	
	joystick.hide()
	
	menu_btn.hide()
	menu_panel.hide()
	shop_panel.show_elegantly()
	
	get_tree().paused = true


func _on_ShopPanel_when_hiden():
	$BlurShader.change_blur_amount(0, 0.5)
	
	joystick.show()
	
	menu_btn.show()
	
	get_tree().paused = false


func _on_Menu_toggled(button_pressed):
	if button_pressed:
		_show_menu()
	else:
		_hide_menu()


func _on_Exit_pressed():
	get_node("/root/Main").loading_panel.load_scene("res://scenes/stages/Home.tscn")


func _on_Languages_pressed():
	# Get current locale.
	var old_locale = TranslationServer.get_locale()
	
	var index = languages_list.find(old_locale)
	
	# Change locale.
	if index > -1:
		index = (index + 1) % languages_list.size()
		var new_locale = languages_list[index]
		Global.change_locale(new_locale)
		
		# Change looking of the language button.
		lang_btn.get_child(0).set_frame(6 + index)
	else:
		Logger.error("Failed to change language!", "HUD")


func _on_SFX_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), button_pressed)


func _on_Music_toggled(button_pressed):
	var bgm_player = get_node_or_null("/root/Main/BgmPlayer")
	
	if bgm_player:
		if button_pressed:
			bgm_player.decrease_volume_to_zero()
		else:
			bgm_player.increase_volume_to_normal()


func _when_locale_changed():
	_update_language()


func _update_language():
	pass
