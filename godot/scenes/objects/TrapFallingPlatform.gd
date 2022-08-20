extends KinematicBody2D

const GRAVITY = 500.0

var linear_velocity = Vector2()


func _ready():
	set_physics_process(false)


func _physics_process(delta):
	linear_velocity.y += GRAVITY * delta
	
	linear_velocity = move_and_slide(linear_velocity, Vector2.UP)


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		$Timer.start()


func _on_Timer_timeout():
	set_physics_process(true)
	$AnimatedSprite.play("off")
	set_collision_mask_bit(0, false)
#	$CollisionShape2D.set_deferred("disabled", true)
