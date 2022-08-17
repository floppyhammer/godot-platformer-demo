extends Control

export (bool) var debug = false

var play_direction = 1

signal appeared
signal disappeared


# Test
func _input(event):
	if debug and event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			appear()
		elif event.button_index == BUTTON_RIGHT:
			disappear()


func disappear():
	$AnimationPlayer.play_backwards("appear")
	play_direction = -1


func appear():
	$AnimationPlayer.play("appear")
	play_direction = 1


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "appear":
		if play_direction == 1:
			emit_signal("appeared")
		else:
			emit_signal("disappeared")
