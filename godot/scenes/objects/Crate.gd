extends RigidBody2D


var hp = 5


func take_damage(value):
	hp -= value
	
	if hp <= 0:
		queue_free()
