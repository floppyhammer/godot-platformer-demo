extends MarginContainer


var languages_list = ["zh", "en"]

onready var lang_btn = $HBox/Language


func _on_SfxButton_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), button_pressed)


func _on_MusicButton_toggled(button_pressed):
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


func _on_Language_pressed():
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


func _on_Exit_pressed():
	get_node("/root/Main").loading_panel.load_scene("res://scenes/stages/Home.tscn")
