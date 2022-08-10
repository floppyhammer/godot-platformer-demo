extends VBoxContainer

"""
Used to display notifications.
"""

var tag_scene = load("res://scenes/ui/NotificationTag.tscn")

export var debug : bool = false


# Test
func _input(event):
	if debug:
		if event is InputEventMouseButton and event.pressed:
			add_notification("Test notification")


func add_notification(text):
	var tag = tag_scene.instance()
	
	tag.text = text
	
#	if content_dict.has("text"):
#		tag.text = content_dict["text"]
	
	add_child(tag)
