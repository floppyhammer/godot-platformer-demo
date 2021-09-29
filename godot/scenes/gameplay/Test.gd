extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var max_speed = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var force = Vector2.ZERO
	if Input.is_key_pressed(KEY_UP):
		force.y += -1
	if Input.is_key_pressed(KEY_DOWN):
		force.y += 1
	if Input.is_key_pressed(KEY_LEFT):
		force.x += -1
	if Input.is_key_pressed(KEY_RIGHT):
		force.x += 1
	
	force *= 100
	
	for body in get_tree().get_nodes_in_group("PhysicalBlock"):
		body.set_applied_force(force)
		
		if abs(body.get_linear_velocity().x) > max_speed or abs(body.get_linear_velocity().y) > max_speed:
			var new_speed = body.get_linear_velocity().normalized()
			new_speed *= max_speed
			body.set_linear_velocity(new_speed)
