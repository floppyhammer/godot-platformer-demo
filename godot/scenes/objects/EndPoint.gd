extends Area2D


func _ready():
	$AnimatedSprite.play("idle")


func _on_EndPoint_body_entered(body):
	if body.is_in_group("player"):
		# End game.
		if Global.hud:
			Global.hud.show_result_panel()
