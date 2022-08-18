extends Area2D


func _ready():
	$AnimatedSprite.play("idle")


func _on_EndPoint_body_entered(body):
	if body.is_in_group("player"):
		# Return to the world map.
		get_node("/root/Main").loading_panel.load_scene("res://scenes/stages/Home.tscn")
