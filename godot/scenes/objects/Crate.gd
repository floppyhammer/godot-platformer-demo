extends KinematicBody2D


const GRAVITY = 500.0
const SPEED = 500.0

var linear_velocity = Vector2()
var hp = 5


func _physics_process(delta):
	linear_velocity.y += GRAVITY * delta
	
	var dir = 0
	if $RayL.get_collider():
		dir = 1
	if $RayR.get_collider():
		dir = -1
		
	linear_velocity.x = dir * SPEED * delta
	linear_velocity = move_and_slide(linear_velocity, Vector2.UP)


func take_damage(value):
	hp -= value
	
	if hp <= 0:
		queue_free()
