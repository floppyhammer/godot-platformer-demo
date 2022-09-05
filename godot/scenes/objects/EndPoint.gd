extends Area2D


export(String) var next_level_id


func _ready():
	$AnimatedSprite.play("closed")


func _on_EndPoint_body_entered(body):
	if body.is_in_group("player"):
		$AnimatedSprite.play("open")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "open":
		# Return to the world map.
		_go_to_level()


func _go_to_level():
	if Global.level_db.has(next_level_id):
		var level_scene_path = Global.level_db[next_level_id]["scene"]
		get_node("/root/Main").loading_panel.load_scene(level_scene_path)
	else:
		_go_to_home()


func _go_to_home():
	get_node("/root/Main").loading_panel.load_scene("res://scenes/stages/Home.tscn")
