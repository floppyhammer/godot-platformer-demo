extends Area2D


func _on_Checkpoint_body_entered(body):
	if body.is_in_group("player"):
		$AnimSprite.play("out")


func _on_AnimSprite_animation_finished():
	if $AnimSprite.animation == "out":
		$AnimSprite.play("idle")
