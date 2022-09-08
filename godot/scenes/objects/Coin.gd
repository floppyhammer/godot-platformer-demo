extends KinematicBody2D


const GRAVITY = 500.0
var velocity : Vector2 = Vector2.ZERO


func _ready():
	$AnimatedSprite.play("idle")


func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	move_and_collide(velocity)


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		$AnimatedSprite.play("collected")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "collected":
		queue_free()
