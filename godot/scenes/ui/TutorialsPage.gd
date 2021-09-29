extends Panel

var page_width = 384
var current_page = 0
var total_pages = 7

var press_pos = null
var release_pos = null

onready var page_title = $CenterC/Panel/VBoxC/PageTitle
onready var scroll_container = $CenterC/Panel/VBoxC/ScrollC
onready var page_box = scroll_container.get_node("HBoxC")
onready var page_number_label = $CenterC/Panel/VBoxC/PageNumber
onready var tween = $Tween


func _reload():
	page_width = scroll_container.rect_size.x
	
	page_title.text = tr("TUTORIAL_TITLE")
	
	for i in range(total_pages):
		page_box.get_child(i).bbcode_text = tr("TUTORIAL_%d" % (i + 1))


func _on_Previous_pressed():
	current_page = clamp(current_page - 1, 0, total_pages - 1)
	
	page_number_label.text = "%d/%d" % [current_page + 1, total_pages]
	
	tween.interpolate_property(scroll_container, "scroll_horizontal", scroll_container.scroll_horizontal, current_page * page_width, 0.4)
	tween.start()


func _on_Next_pressed():
	current_page = clamp(current_page + 1, 0, total_pages - 1)
		
	page_number_label.text = "%d/%d" % [current_page + 1, total_pages]

	tween.interpolate_property(scroll_container, "scroll_horizontal", scroll_container.scroll_horizontal, current_page * page_width, 0.4)
	tween.start()


func _on_TutorialPage_visibility_changed():
	if visible:
		_reload()


func _on_VBoxC_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			press_pos = event.position
		else:
			release_pos = event.position
			
			var drag_vec = release_pos - press_pos
			
			if drag_vec.x > 32:
				_on_Previous_pressed()
			elif drag_vec.x < -32:
				_on_Next_pressed()


func _on_TutorialPage_gui_input(event):
	if event is InputEventScreenTouch:
		if not event.pressed:
			hide()


func _on_TutorialsPage_item_rect_changed():
	if is_instance_valid(page_box):
		for i in range(total_pages):
			page_box.get_child(i).rect_min_size.x = scroll_container.rect_size.x
			page_width = scroll_container.rect_size.x
