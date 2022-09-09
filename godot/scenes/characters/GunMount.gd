extends Area2D

"""
Every time you die, your spirit becomes more powerful.
"""

export (NodePath) var player_node

var target_position : Vector2
var speed = 0.2
var face2 = 1

var targets = []
var current_target

var bullet_scene = preload("res://scenes/objects/Bullet.tscn")

var can_fire = true

onready var flip = $Flip


func _physics_process(delta):
	var player = get_node_or_null(player_node)
	
	$Label.text = "Targets: %s" % str(targets)
	
	if is_instance_valid(current_target):
		$VisionRay.look_at(current_target.global_position)
		
		if can_fire:
			can_fire = false
			$FiringTimer.start()
			_fire()
	else:
		$VisionRay.look_at(global_position + face2 * Vector2(1, 0))
	
	if is_instance_valid(player):
		face2 = player.get_face2()
		
		target_position = player.get_gun_position()
		
		position = position.linear_interpolate(target_position, speed)
	
	flip.scale.x = face2 * abs(flip.scale.x)
	$Flip/Gun.face_to = face2


func _on_AttackArea_body_entered(body):
	if not body.is_in_group("enemy"): return
	
	if not targets.has(body):
		targets.append(body)
		
		current_target = targets.front()


func _on_AttackArea_body_exited(body):
	targets.erase(body)
	
	if targets.size() > 0:
		current_target = targets.front()
	else:
		current_target = null


func _fire():
	var player = get_node_or_null(player_node)
	
	if is_instance_valid(player):
		var new_bullet = bullet_scene.instantiate()
		
		new_bullet.prepare(global_position, Math.rot2vec($VisionRay.rotation) * 400, player)
		get_parent().add_child(new_bullet)


func _on_FiringTimer_timeout():
	can_fire = true
