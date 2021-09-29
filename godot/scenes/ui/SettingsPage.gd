extends Panel

var is_appearing = false
var languages = ["zh", "en"]

onready var panel = $CenterC/Panel
onready var page_title = $CenterC/Panel/VBoxC/PageTitle
onready var lang_btn = $CenterC/Panel/VBoxC/Languages
onready var tutorials_btn = $CenterC/Panel/VBoxC/Tutorials
onready var about_btn = $CenterC/Panel/VBoxC/About
onready var tween = $Tween


func _ready():
	# Reset transition state.
	hide()
	modulate = Color.transparent
	
	_update_language()
	Global.connect("locale_changed", self, "_when_locale_changed")


func _when_locale_changed():
	_update_language()


func _update_language():
	page_title.text = tr("SETTINGS")
	lang_btn.text = tr("LANGUAGES")
	tutorials_btn.text = tr("TUTORIALS")
	about_btn.text = tr("ABOUT")


func show_elegantly():
	is_appearing = true
	show()
	
	tween.remove_all()
	tween.interpolate_property(self, "modulate", modulate, Color.white, 0.2)
	tween.start()


func hide_elegantly():
	is_appearing = false
	
	# Save settings offline.
	Global.save_general_save_data()
	
	tween.remove_all()
	tween.interpolate_property(self, "modulate", modulate, Color.transparent, 0.2)
	tween.start()


func _on_Tutorials_pressed():
	$TutorialsPage.show()


func _on_About_pressed():
	$AboutPage.show()


func _on_SFX_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), button_pressed)


func _on_Music_toggled(button_pressed):
	var bgm_player = get_node_or_null("/root/Main/BGMPlayer")
	
	if bgm_player:
		if button_pressed:
			bgm_player.decrease_volume_to_zero()
		else:
			bgm_player.increase_volume_to_normal()


func _on_Languages_pressed():
	var index = languages.find(TranslationServer.get_locale())
	if index > -1:
		index = (index + 1) % languages.size()
		Global.change_locale(languages[index])


func _on_Tween_tween_all_completed():
	if is_appearing:
		pass
	else:
		hide()


func _on_Close_pressed():
	hide_elegantly()
