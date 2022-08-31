extends Area2D


func _ready():
	$AnimatedSprite.play("closed")


func _on_EndPoint_body_entered(body):
	if body.is_in_group("player"):
		$AnimatedSprite.play("open")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "open":
		# Return to the world map.
		get_node("/root/Main").loading_panel.load_scene("res://scenes/stages/Home.tscn")
