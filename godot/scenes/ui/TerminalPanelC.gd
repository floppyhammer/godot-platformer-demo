extends Panel

var is_appearing = false

var tab_btns_group = ButtonGroup.new()

onready var tab_container = $HBoxC/TabC

onready var guardian_page = $HBoxC/TabC/TerminalGuardian
onready var items_page = $HBoxC/TabC/TerminalItems
onready var achievements_page = $HBoxC/TabC/TerminalAchievements

onready var guardians_btn = $HBoxC/VBoxC/Guardians
onready var items_btn = $HBoxC/VBoxC/Items
onready var achievements_btn = $HBoxC/VBoxC/Achievements

onready var tween = $Tween
onready var panel = $HBoxC


func _ready():
	for child in $HBoxC/VBoxC.get_children():
		if child.name != "Close":
			child.group = tab_btns_group


func show_elegantly():
	is_appearing = true
	
	modulate = Color.transparent
	show()
	
	tween.remove_all()
	tween.interpolate_property(self, "modulate", modulate, Color.white, 0.2)
	tween.start()
	
	guardian_page.reset()
	items_page.reset()
	achievements_page.reset()
	
	tab_container.current_tab = 0
	guardians_btn.pressed = true


func hide_elegantly():
	# Save settings locally
	Global.save_general_save_data()
	
	is_appearing = false
	
	tween.remove_all()
	tween.interpolate_property(self, "modulate", modulate, Color.transparent, 0.2)
	tween.start()


func _on_AnimationPlayer_animation_finished(anim_name):
	if is_appearing:
		pass
	else:
		hide()


func _on_Guardians_pressed():
	tab_container.current_tab = 0


func _on_Items_pressed():
	tab_container.current_tab = 1


func _on_Achievements_pressed():
	tab_container.current_tab = 2


func _on_Close_pressed():
	hide_elegantly()


func _on_Tween_tween_all_completed():
	if is_appearing:
		pass
	else:
		hide()
