extends Panel


var level_btn_group = ButtonGroup.new()

onready var tween = $Tween
onready var level_btns = $ScrollContainer/CenterContainer/Levels


func _ready():
	# No pause for the home scene.
	get_tree().paused = false
	
	# Translation.
	_when_locale_changed()
	Global.connect("locale_changed", self, "_when_locale_changed")

	# Connect signal and add to group
	for btn in level_btns.get_children():
		btn.connect("pressed", self, "_when_button_pressed")
		btn.set_button_group(level_btn_group)

	# Update the level buttons' looking.
	update_level_buttons()


# When a button in the group is pressed.
func _when_button_pressed():
	var level_name = level_btn_group.get_pressed_button().level_id
	_start_level(level_name)


func update_level_buttons():
	var incomplete_count = 0
	
	# Traverse level buttons.
	for i in range(level_btns.get_child_count()):
		# Get level name from the button.
		var key = level_btns.get_child(i).level_id
		
		# Get star number.
		var star_number = 0
		var level_progress = Global.get_level_progress()
		if level_progress.has(key):
			star_number = level_progress[key]["stars"]
		
		# Disable locked levels.
		var playable = false
		if star_number == 0:
			incomplete_count += 1
		if incomplete_count > 1:
			playable = false
		else:
			playable = true

		# Update the button
		level_btns.get_child(i).update_looking(star_number, playable)


func hide_levels():
	tween.remove_all()
	tween.interpolate_property(level_btns, "modulate", Color.white, Color.transparent, 0.2)
	tween.start()
	yield(tween, "tween_all_completed")
	level_btns.hide()


func show_levels():
	level_btns.show()
	tween.remove_all()
	tween.interpolate_property(level_btns, "modulate", Color.transparent, Color.white, 0.2)
	tween.start()


func _start_level(level_name):
	# Retrieve level info
	var level_config = Global.level_db[level_name]
	Global.current_level_name = level_name
	
	# Change scene with transition
	var main_node = get_node_or_null("/root/Main")
	if main_node:
		main_node.loading_panel.load_scene("res://scenes/levels/L1-1TheBegining.tscn")
		main_node.bgm_player.stop_bgm()


func _when_locale_changed():
	pass


func _on_Exit_pressed():
	get_tree().quit()
