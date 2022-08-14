extends CharacterBody2D


const SPEED = 50.0

enum FaceDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

var face_to = FaceDirection.UP


func _physics_process(delta):
	var dir = Vector2.ZERO
	
	var anim_to_play = ""
	
	if Input.is_action_pressed('ui_down'):
		anim_to_play = "walk-down"
		dir.y = 1
		face_to = 0
		face_to = FaceDirection.DOWN
	if Input.is_action_pressed('ui_up'):
		anim_to_play = "walk-up"
		dir.y = -1
		face_to = 1
		face_to = FaceDirection.UP
	if Input.is_action_pressed('ui_left'):
		anim_to_play = "walk-left"
		dir.x = -1
		face_to = FaceDirection.LEFT
	if Input.is_action_pressed('ui_right'):
		anim_to_play = "walk-right"
		dir.x = 1
		face_to = FaceDirection.RIGHT
	
	dir = dir.normalized()
	
	velocity = dir * SPEED
	move_and_slide()
	
	if dir == Vector2.ZERO:
		match face_to:
			FaceDirection.DOWN:
				anim_to_play = "idle-down"
			FaceDirection.UP:
				anim_to_play = "idle-up"
			FaceDirection.LEFT:
				anim_to_play = "idle-left"
			FaceDirection.RIGHT:
				anim_to_play = "idle-right"
	
	$AnimatedSprite2D.play(anim_to_play)
	
	if dir != Vector2.ZERO:
		$InteractRay.target_position = dir * 10
	
	if Input.is_action_just_pressed('interact'):
		var collider = $InteractRay.get_collider()
		if collider and collider.has_method("interact"):
			collider.interact()
