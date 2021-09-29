extends Panel


func _ready():
	hide()


func _on_AchievementPage_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			hide()
