extends PanelContainer

var items_to_bring = ["", "", ""]
var current_item_slot = 0

onready var level_label = $CenterC/PanelC/VBoxC/Level
onready var target_label = $CenterC/PanelC/VBoxC/Target
onready var item_list = $ItemsPanel/CenterC/VBoxC/ItemList


func _ready():
	hide()
	$ItemsPanel.hide()
	#show_with_transition()


func prepare(level_name, target_score):
	# Set up level info
	$CenterC/PanelC/VBoxC/Start.text = tr("START")
	level_label.text = tr("LEVEL_NAME") % level_name
	target_label.bbcode_text = tr("TARGET_DESCRIPTION_A") % target_score


func show_with_transition():
	show()
	$AnimPlayer.play("appear")


func hide_with_transition():
	$AnimPlayer.play("disappear")
	
	for i in range(3):
		$CenterC/PanelC/VBoxC/ItemHBoxC.get_child(i).texture_normal = load("res://assets/ui/button_plus.png")
		if items_to_bring[i] != "":
			Global.item_progress[items_to_bring[i]]["amount"] += 1
	items_to_bring = ["", "", ""]


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "disappear":
		hide()


func _on_StartPanel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			hide_with_transition()



func _on_Start_pressed():
	# Change scene with transition
	Global.items_to_bring = items_to_bring
	get_node("/root/Main").loading_panel.load_scene("res://scenes/levels/Level0.tscn")
	get_node("/root/Main").bgm_player.stop_bgm()


func _on_ItemList_item_selected(index):
	$ItemsPanel.hide()
	
	var item_key = item_list.get_item_metadata(index)
	
	if item_key == "":
		$CenterC/PanelC/VBoxC/ItemHBoxC.get_child(current_item_slot).texture_normal = load("res://assets/ui/button_plus.png")
		if items_to_bring[current_item_slot] != "":
			Global.item_progress[items_to_bring[current_item_slot]]["amount"] += 1
	else:
		$CenterC/PanelC/VBoxC/ItemHBoxC.get_child(current_item_slot).texture_normal = item_list.get_item_icon(index)
		Global.item_progress[item_key]["amount"] -= 1
	
	items_to_bring[current_item_slot] = item_key


func _on_AddButton1_pressed():
	_reload_items()
	$ItemsPanel.show()
	current_item_slot = 0


func _on_AddButton2_pressed():
	_reload_items()
	$ItemsPanel.show()
	current_item_slot = 0
	current_item_slot = 1


func _on_AddButton3_pressed():
	_reload_items()
	$ItemsPanel.show()
	current_item_slot = 0
	current_item_slot = 2


func _reload_items():
	item_list.clear()
	
	item_list.add_item("", load("res://assets/ui/icons/minus.png"))
	item_list.set_item_metadata(item_list.get_item_count() - 1, "")
	
	for key in Global.item_progress:
		if Global.item_progress[key]["amount"] > 0:
			item_list.add_item(str(Global.item_progress[key]["amount"]), load(Global.item_db[key]["texture"]))
			item_list.set_item_metadata(item_list.get_item_count() - 1, key)


func _on_Back_pressed():
	pass # Replace with function body.
