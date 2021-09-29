extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_EndPoint_body_entered(body):
	if body.is_in_group("player"):
		$AnimatedSprite.play("moving")
		
		# End game.
		if Global.hud:
			Global.hud.show_result_panel()
