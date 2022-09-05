extends Panel


var is_appearing = false

onready var tween = $Tween

var is_music_on = true
var is_sfx_on = true

var languages_list = ["zh", "en"]

onready var lang_btn = $TextureRect/MarginContainer/VBoxContainer/GridContainer/Language

signal when_closed
signal level_restarted


func show_elegantly():
	is_appearing = true
	
	modulate = Color.transparent
	show()
	
	tween.remove_all()
	tween.interpolate_property(self, "modulate", modulate, Color.white, 0.2)
	tween.start()


func hide_elegantly():
	is_appearing = false
	
	tween.remove_all()
	tween.interpolate_property(self, "modulate", modulate, Color.transparent, 0.2)
	tween.start()
	
	emit_signal("when_closed")


func _on_AnimationPlayer_animation_finished(anim_name):
	if is_appearing:
		pass
	else:
		hide()


func _on_Close_pressed():
	hide_elegantly()


func _on_Tween_tween_all_completed():
	if is_appearing:
		pass
	else:
		hide()


func _on_Music_pressed():
	var bgm_player = get_node_or_null("/root/Main/BgmPlayer")
	
	if bgm_player:
		if is_music_on:
			bgm_player.increase_volume_to_normal()
		else:
			bgm_player.decrease_volume_to_zero()


func _on_Sfx_pressed():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not is_sfx_on)


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
		lang_btn.find_node("Icon").set_frame(6 + index)
	else:
		Logger.error("Failed to change language!", "HUD")


func _on_Restart_pressed():
	get_tree().paused = false
	
	var level_scene_path = Global.level_db[Global.current_level_id]["scene"]
	get_node("/root/Main").loading_panel.load_scene(level_scene_path)
	
	emit_signal("level_restarted")


func _on_Exit_pressed():
	get_node("/root/Main").loading_panel.load_scene("res://scenes/stages/Home.tscn")
