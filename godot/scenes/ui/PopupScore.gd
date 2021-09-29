extends Control


func prepare(score, position):
	$Centre/Label.text = str(score)
	rect_position = position


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
