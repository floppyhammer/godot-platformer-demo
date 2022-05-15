extends Panel

var level_btn_scene = preload("res://scenes/ui/LevelButton.tscn")
var level_btn_group = ButtonGroup.new()

var progress_ratio = 0
var scroll_ratio = 0

onready var tween = $Tween
onready var scroll_container = $ScrollC
onready var scroll_content = scroll_container.get_node("WorldMap")

signal level_pressed


func _ready():
	# Connect signal and add to group
	for btn in scroll_content.get_children():
		btn.connect("pressed", self, "_when_button_pressed")
		btn.set_button_group(level_btn_group)
	
	# Update the level buttons' looking.
	update_level_buttons()
	
	# Set scroll position.
	set_scroll_ratio(0.5)


func get_scroll_ratio():
	var result
	if not (scroll_content.rect_size.y - scroll_container.rect_size.y) == 0:
		result = scroll_container.get_v_scroll() / (scroll_content.rect_size.y - scroll_container.rect_size.y)
	else:
		result = 0
	return result


func set_scroll_ratio(ratio):
	# Calling yield(get_tree(), "idle_frame") before set_v_scroll will make it works
	yield(get_tree(), "idle_frame")
	
	scroll_container.set_v_scroll(ratio * (scroll_content.rect_size.y - scroll_container.rect_size.y))


func _process(delta):
	scroll_ratio = get_scroll_ratio()


# When a button in the group is pressed
func _when_button_pressed():
	var level_name = level_btn_group.get_pressed_button().level_id
	emit_signal("level_pressed", level_name)


func update_level_buttons():
	var incomplete_count = 0
	
	# Traverse level buttons.
	for i in range(scroll_content.get_child_count()):
		# Get level name from the button.
		var key = scroll_content.get_child(i).level_id
		
		# Get star number.
		var star_number = 0
		if Global.level_progress.has(key):
			star_number = Global.level_progress[key]["stars"]
		
		# Disable locked levels.
		var playable = false
		if star_number == 0:
			incomplete_count += 1
		if incomplete_count > 1:
			playable = false
		else:
			playable = true
		
		# Scroll ratio of the current level.
		if incomplete_count == 1:
			progress_ratio = 1.0 - (scroll_content.get_child(i).rect_position.y - scroll_container.rect_size.y) / (scroll_content.rect_size.y)
		
		# Update the button
		scroll_content.get_child(i).update_looking(star_number, playable)


func hide_levels():
	tween.remove_all()
	tween.interpolate_property(scroll_content, "modulate", Color.white, Color.transparent, 0.2)
	tween.start()
	yield(tween, "tween_all_completed")
	scroll_content.hide()


func show_levels():
	scroll_content.show()
	tween.remove_all()
	tween.interpolate_property(scroll_content, "modulate", Color.transparent, Color.white, 0.2)
	tween.start()
