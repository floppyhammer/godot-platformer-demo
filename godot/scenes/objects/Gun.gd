extends Node2D

export (bool) var debug = false

onready var bullet_scene = preload("res://scenes/objects/Bullet.tscn")

var face_to = 1


# Test
func _input(event):
	if debug and event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			fire()
	
	if Input.is_action_just_pressed("interact"):
		fire()


func fire():
	var bullet = bullet_scene.instance()
	bullet.prepare($Muzzle.get_global_position(), Vector2(face_to * 300, 0))
	
	if debug:
		get_parent().add_child(bullet)
	else:
		Global.current_level.add_object(bullet)
