extends KinematicBody2D


"""Can be thrown by the player, as a weapon!"""

const GRAVITY = 500.0
const SPEED = 100.0

var linear_velocity = Vector2()
var target_position = Vector2()
var is_lift = false


func _physics_process(delta):
	if is_lift:
		if is_instance_valid(Global.player):
			var face2 = Global.player.get_face2()
			
			target_position = Global.player.get_lift_position()
			
			linear_velocity = Vector2.ZERO
			position = position.linear_interpolate(target_position, 0.2)
	else:
		linear_velocity.y += GRAVITY * delta
		
		linear_velocity = move_and_slide(linear_velocity, Vector2.UP)
		#move_and_collide(linear_velocity * 0.01)
		
		if is_on_floor():
			linear_velocity.x *= 0.5


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		$AnimSprite.play("active")


func interact():
	if is_lift:
		is_lift = false
		var face2 = Global.player.get_face2()
		linear_velocity = Vector2(face2, -1) * SPEED
	else:
		is_lift = true
		Global.player.currently_interacting_object = self
