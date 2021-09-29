extends TextureRect

onready var anim_player = $AnimPlayer


func update_looking(block_id : int):
	# Reset scale.
	rect_scale = Vector2.ONE
	
	# Set ID label.
	if block_id != 0:
		$Id.text = str(block_id)
	else:
		$Id.text = ""


func merge(des):
	anim_player.play("merge")
	
	$VFX.frame = 0
	$VFX.play("merge")
	$Merge.play()
	
	$Tween.remove_all()
	$Tween.interpolate_property(self, "rect_position", rect_position, des, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func explode():
	$VFX.frame = 0
	$VFX.play("explode")
	
	$Explode.play()


func _on_Block_item_rect_changed():
	$VFX.position = 0.5 * rect_size
