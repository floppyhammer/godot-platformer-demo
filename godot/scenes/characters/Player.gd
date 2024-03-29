extends KinematicBody2D

# Player does't attack. It's like playing Celeste.
# Attack is done by her guardian. It's like playing bullet hell games.

const SPEED = 70.0
const IN_WATER_SPEED = SPEED / 2
const JUMP_SPEED = 170.0
const GRAVITY = 500.0
const ACCEL = 10.0

var grav = GRAVITY
var guardian_lift : float = 0.01

var max_hp = 100.0
var hp = max_hp

var linear_velocity = Vector2()
var velx2reach = 0
var face2 = 1

var bodies_in_sight = []
var is_dead = false

onready var flip = $Flip
onready var anim_sprite = $Flip/AnimatedSprite
onready var anim_player = $AnimationPlayer
onready var anim_state_machine = $AnimationTree.get("parameters/playback")
onready var col_shape = $CollisionShape2D
onready var lift_position = $LiftPosition
onready var gun_position = $GunPosition

var can_evade_damage = false
var interruptible_anims = ['idle', 'run', 'jump', 'fall', 'crouch_loop']
var is_self_jumped = false

var currently_interacting_object = null

signal took_damage
signal when_respawned


func _ready():
	#col_shape.disabled = true
	_sync_anim()
	
	Engine.time_scale = 1
	
	Global.player = self


func _process(delta):
		# Flip the sprite according to face direction
	flip.scale.x = face2 * abs(flip.scale.x)
	$InteractRay.cast_to.x = face2 * abs($InteractRay.cast_to.x)
	
	# Set the animation according to the tree
	anim_sprite.play(anim_state_machine.get_current_node())
	
	$Label.text = anim_state_machine.get_current_node()
	$Label.text += '-' + str(anim_sprite.frame)


func _physics_process(delta):
	_control()
	
	if Input.is_action_just_pressed("interact") and Global.player_input_enabled:
		if is_instance_valid(currently_interacting_object):
			currently_interacting_object.interact()
			currently_interacting_object = null
		else:
			var collider = $InteractRay.get_collider()
			if collider and collider.has_method("interact"):
				collider.interact()
	
	linear_velocity.x = lerp(linear_velocity.x, velx2reach * face2, delta * ACCEL)
	
	if linear_velocity.y > 0:
		linear_velocity.y += grav * delta
	else:
		if is_self_jumped and Input.is_action_pressed("ui_accept") and Global.player_input_enabled:
			linear_velocity.y += grav * 0.5 * delta
		else:
			linear_velocity.y += grav * delta
	
	if is_on_ceiling():
		is_self_jumped = false
		#$SFX/HitCeiling.play()
	
	linear_velocity = move_and_slide(linear_velocity, Vector2.UP)

	#vel = move_and_slide_with_snap(vel, Vector2.DOWN, Vector2.UP, true, 1.0)
	#_deal_with_sliding_on_slopes()


func _deal_with_sliding_on_slopes():
	if is_on_floor() and velx2reach == 0.0:
		linear_velocity *= 0.0


func _control():
	velx2reach = 0.0
	
	if not Global.player_input_enabled:
		return
	
	var anim : String = anim_state_machine.get_current_node()
	
	# Cannot control during un-interruptible animations
	if not anim in interruptible_anims:
		match anim:
			'attack':
				velx2reach = 0.0
			'roll':
				if anim_sprite.frame > 5:
					velx2reach = 0.0
					can_evade_damage = false
				else:
					velx2reach = 150.0
					can_evade_damage = true
	else:
		# ACT: Move
		var direction = Vector2.ZERO
		if Input.is_action_pressed('ui_left'):
			face2 = -1
			velx2reach = SPEED
		if Input.is_action_pressed('ui_right'):
			face2 = 1
			velx2reach = SPEED
		
		# ACT: Jump
		if is_on_floor():
			if Input.is_action_just_pressed('jump'):
				linear_velocity.y -= JUMP_SPEED
				#$SFX/Jump.play()
				is_self_jumped = true
				# Reset jump state
		
		if linear_velocity.y > 0 and is_self_jumped:
			is_self_jumped = false
	
	# ACT: Attack
#	if is_on_floor() and Input.is_action_just_pressed('attack'):
##		if anim == 'attack_1':
##			anim_state_machine.travel('attack_2')
##		elif anim == 'attack_2':
##			anim_state_machine.travel('attack_3')
##		else:
##			anim_state_machine.travel('attack_1')
#
#		anim_state_machine.travel('attack')
#		return
	
	# ACT: Roll
#	if is_on_floor() and Input.is_action_just_pressed('roll'):
#		# Can roll only when running fast.
#		if abs(linear_velocity.x) > SPEED * 0.5:
#			anim_state_machine.travel('roll')
#			return
	
	# ANIM: Idle or run
	if anim in interruptible_anims:
		if is_on_floor():
			if Input.is_action_pressed('ui_left') \
				or Input.is_action_pressed('ui_right'):
				anim_state_machine.travel('run')
			else:
				anim_state_machine.travel('idle')
			
			if Input.is_action_pressed('ui_down'):
				velx2reach = 0
				if anim != 'crouch' or anim != 'crouch_loop':
					anim_state_machine.travel('crouch_loop')
					return
			elif anim == 'crouch' or anim == 'crouch_loop':
				anim_state_machine.travel('idle')
				return
		# ANIM: Jump or fall
		else:
			if linear_velocity.y > 0:
				anim_state_machine.travel('fall')
			else:
				anim_state_machine.travel('jump')
	return


func take_damage(damage):
	emit_signal('took_damage')
	
#	if not $ImmortalTimer.is_stopped():
#		return
#
#	$ImmortalTimer.start()
#	$AdditionalAnimationPlayer.play('hit')
#
#	# 擦弹
#	if can_evade_damage:
#		$SFX/Evade.play()
#		$AttackBonusTimer.start()
#		$ImmortalTimer.start()
#		print('Attack bonus time starts.')
#		return
#
#	if damage < 20:
#		if not $SFX/Hit.playing:
#			$SFX/Hit.play()
#	else:
#		if not $SFX/HitCritical.playing:
#			$SFX/HitCritical.play()
#
#	# Shake the camera
#	Global.current_camera.shake(0.5)
#
#	# Change HP
#	hp -= damage
#	hp = clamp(hp, 0.0, max_hp)
#
#	# Handle death
#	if hp == 0.0:
#		die()


func die():
	if is_dead: return
	
	is_dead = true
	
	set_physics_process(false)
	
	#$SFX/Die.play()
	anim_state_machine.travel('die')


func respawn():
	set_physics_process(true)
	is_dead = false
	anim_state_machine.travel('idle')
	linear_velocity = Vector2.ZERO
	emit_signal("when_respawned")


# Loop should be properly set for both anim_player and anim_sprite.
func _sync_anim():
	# Sync AnimationPlayer's animations with AnimatedSprite
	for anim in anim_player.get_animation_list():
		# Get the frame number and FPS of the AnimatedSprite animation
		var frame_count : float = anim_sprite.get_sprite_frames().get_frame_count(anim)
		var frame_fps : float = anim_sprite.get_sprite_frames().get_animation_speed(anim)
		
		var anim_length = round(frame_count / frame_fps * 1000.0) / 1000.0
		
		# Set them to the AnimationPlayer animation
		anim_player.get_animation(anim).set_length(anim_length)


func _on_AnimatedSprite_frame_changed():
	var anim = anim_sprite.animation
	var fram = anim_sprite.frame
	
	match anim:
		'attack_1':
			if fram == 1:
				pass
				#$SFX/Attack1.play()
				
			if fram == 0:
				pass
				#$flip/AttackAreaA/CollisionShape2D.disabled = false
			else:
				pass
				#$flip/AttackAreaA/CollisionShape2D.disabled = true
		
		'attack_2':
			if fram == 1:
				pass
				#$SFX/Attack2.play()
				
			if fram == 2:
				pass
				#$flip/AttackAreaA/CollisionShape2D.disabled = false
			else:
				pass
				#$flip/AttackAreaA/CollisionShape2D.disabled = true
	
		'attack_3':
			if fram == 1:
				pass
				#$SFX/Attack3.play()
				
			if fram == 4:
				pass
				#$flip/AttackAreaA/CollisionShape2D.disabled = false
			else:
				pass
				#$flip/AttackAreaA/CollisionShape2D.disabled = true
	
#	if not $AttackBonusTimer.is_stopped():
#		Engine.time_scale = 0.75
#		$Shadows.add_frame(anim_sprite.frames.get_frame(anim_sprite.animation, anim_sprite.frame), face2)
#	else:
#		Engine.time_scale = 1.0


func get_lift_position() -> Vector2:
	if Input.is_action_pressed('ui_down'):
		return lift_position.get_global_position() + Vector2.DOWN * 4
		
	return lift_position.get_global_position()


func get_gun_position() -> Vector2:
	if Input.is_action_pressed('ui_down'):
		return gun_position.get_global_position() + Vector2.DOWN * 4
		
	return gun_position.get_global_position()


func get_face2() -> int:
	return face2


func _on_AttackBonusTimer_timeout():
	print('Attack bonus time ends.')


func _on_ImmortalTimer_timeout():
	pass
	#$AdditionalAnimationPlayer.play('normal')


func _on_AnimatedSprite_animation_finished():
	if anim_sprite.animation == "die":
		respawn()
