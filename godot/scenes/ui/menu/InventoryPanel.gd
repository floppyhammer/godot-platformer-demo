extends Panel


var is_appearing = false

var tab_btns_group = ButtonGroup.new()

onready var tab_container = $HBox/Tabs

onready var status_tab = $HBox/Tabs/TabStatus
onready var items_tab = $HBox/Tabs/TabItems
onready var achievements_tab = $HBox/Tabs/TabAchievements

onready var status_btn = $HBox/TabButtons/Status
onready var items_btn = $HBox/TabButtons/Items
onready var achievements_btn = $HBox/TabButtons/Achievements

onready var tween = $Tween
onready var tab_btns = $HBox/TabButtons


func _ready():
	for child in tab_btns.get_children():
		if child.name != "Close":
			child.group = tab_btns_group


func show_elegantly():
	is_appearing = true
	
	modulate = Color.transparent
	show()
	
	tween.remove_all()
	tween.interpolate_property(self, "modulate", modulate, Color.white, 0.2)
	tween.start()
	
	status_tab.reset()
	items_tab.reset()
	achievements_tab.reset()
	
	tab_container.current_tab = 0
	status_btn.pressed = true


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
