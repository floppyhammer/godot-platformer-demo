extends Panel


var level_group = ButtonGroup.new()

var current_chapter = 0
var chapter_panel_width = 720

onready var tween = $Tween

onready var winter_panel = $HBoxC/ChapterWinter
onready var spring_panel = $HBoxC/ChapterSpring
onready var summer_panel = $HBoxC/ChapterSummer

onready var winter_levels = $HBoxC/ChapterWinter/Levels
onready var spring_levels = $HBoxC/ChapterSpring/Levels
onready var summer_levels = $HBoxC/ChapterSummer/Levels

onready var last_button = $MarginC/HBoxC/LastChapter
onready var next_button = $MarginC/HBoxC/NextChapter


func _ready():
	# No pause for the home scene.
	get_tree().paused = false
	
	# Translation.
	_when_locale_changed()
	Global.connect("locale_changed", self, "_when_locale_changed")

	for btn in winter_levels.get_children():
		btn.set_button_group(level_group)
	
	for btn in spring_levels.get_children():
		btn.set_button_group(level_group)
	
	for btn in summer_levels.get_children():
		btn.set_button_group(level_group)

	# Buttons in the group have to be in toggle mode to trigger this signal.
	level_group.connect("pressed", self, "_when_button_pressed")

	# Update the level buttons' looking.
	update_level_buttons()
	
	chapter_panel_width = rect_size.x
	
	last_button.hide()


# When a button in the group is pressed.
func _when_button_pressed(btn):
	Logger.info("Level button pressed: " + str(btn.level_id))
	var level_name = btn.level_id
	_start_level(level_name)


func update_level_buttons():
	var incomplete_count = 0
	
	# Traverse level buttons.
	for btn in level_group.get_buttons():
		# Get level name from the button.
		var key = btn.level_id
		
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
		btn.update_looking(star_number, playable)


func _start_level(level_name):
	# Retrieve level info
	var level_config = Global.level_db[level_name]
	Global.current_level_name = level_name
	
	var scene_path = level_config["scene"]
	
	# Change scene with transition
	var main_node = get_node_or_null("/root/Main")
	if main_node:
		main_node.loading_panel.load_scene(scene_path)
		main_node.bgm_player.stop_bgm()


func _when_locale_changed():
	pass


func _on_Exit_pressed():
	get_tree().quit()


func _on_LastChapter_pressed():
	if current_chapter == 0:
		return
	
	current_chapter -= 1
	_shift_chapter_panel()


func _on_NextChapter_pressed():
	if current_chapter >= 2:
		return
	
	current_chapter += 1
	_shift_chapter_panel()


func _shift_chapter_panel():
	tween.remove_all()
	tween.interpolate_property($HBoxC, "rect_position", $HBoxC.rect_position, Vector2(-chapter_panel_width * current_chapter, 0), 0.5)
	tween.start()
	yield(tween, "tween_all_completed")
	
	if current_chapter == 0:
		last_button.hide()
	else:
		last_button.show()
	
	if current_chapter == 2:
		next_button.hide()
	else:
		next_button.show()


func _on_Home_item_rect_changed():
	if not winter_panel: return
	
	chapter_panel_width = rect_size.x
	winter_panel.rect_min_size = rect_size
	spring_panel.rect_min_size = rect_size
	summer_panel.rect_min_size = rect_size
