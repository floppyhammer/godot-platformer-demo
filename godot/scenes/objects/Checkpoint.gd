extends Area2D


func _on_Checkpoint_body_entered(body):
	if body.is_in_group("player"):
		$AnimSprite.play("active")
		$AnimationPlayer.play("tip")
