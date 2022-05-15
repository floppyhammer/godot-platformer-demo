extends VBoxContainer

"""
Used to display notifications.
"""

var tag_scene = load("res://scenes/ui/NotificationTag.tscn")

export var debug : bool = false

# Test
func _input(event):
	if debug and Input.is_action_just_pressed("ui_accept"):
		add_notification("Test notification")


func add_notification(text):
	var tag = tag_scene.instance()
	
	tag.text = text
	
#	if content_dict.has("text"):
#		tag.text = content_dict["text"]
	
	add_child(tag)
