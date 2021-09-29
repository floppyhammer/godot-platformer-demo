extends Control

var is_appearing = false
onready var tween = $Tween


func _ready():
	hide()
	
	_update_language()
	Global.connect("locale_changed", self, "_when_locale_changed")
	
	get_node("/root/Main/AdMob").connect("rewarded", self, "_on_AdMob_rewarded")


func _on_AdMob_rewarded(what_reward, ammount):
	print("Rewarded with %d %s" % [ammount, what_reward])
	prepare(what_reward, ammount)
	show_elegantly()


func prepare(what_reward, ammount):
	pass


func _when_locale_changed():
	_update_language()


func _update_language():
	$Panel/VBoxC/PageTitle.text = tr("GIFTS")


func show_elegantly():
	is_appearing = true
	show()
	tween.interpolate_property(self, "self_modulate", self_modulate, Color.white, 0.2)
	tween.interpolate_property($Panel, "rect_scale", Vector2.ZERO, Vector2.ONE, 0.2)
	tween.start()


func hide_elegantly():
	is_appearing = false
	tween.interpolate_property(self, "self_modulate", self_modulate, Color.transparent, 0.2)
	tween.interpolate_property($Panel, "rect_scale", Vector2.ONE, Vector2.ZERO, 0.2)
	tween.start()


func _on_RewardPage_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			hide_elegantly()


func _on_Tween_tween_all_completed():
	if is_appearing:
		pass
	else:
		hide()
