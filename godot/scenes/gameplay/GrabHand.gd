extends Node2D

var default_pos = Vector2.ZERO
var merge_stick_block = false
# GO: 0.1s
# BACK: 0.2s

func go_to(pos, merge_stick_block):
	$Tween.stop_all()
	$Tween.interpolate_property(self, "position", Vector2(pos.x, position.y), pos, 0.1)
	$Tween.interpolate_property(self, "position", pos, Vector2(pos.x, default_pos.y), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.1)
	$Tween.start()
	self.merge_stick_block = merge_stick_block
	# When the stick will arrive at the target block position
	$ArrivalTimer.start()


func _on_ArrivalTimer_timeout():
	if merge_stick_block:
		$Blocks.get_child(0).texture = null
		merge_stick_block = false
