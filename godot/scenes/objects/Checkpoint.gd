extends Area2D


func _on_Checkpoint_body_entered(body):
	if body.is_in_group("player"):
		$Particles2D.emitting = true


func _on_Checkpoint_body_exited(body):
	if body.is_in_group("player"):
		$Particles2D.emitting = false
