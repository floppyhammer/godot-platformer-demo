extends Area2D

export var damage = 10
var vel = Vector2.ZERO
var hit = false

var col_exceptions = []

onready var life_timer = $LifeTimer
onready var shape = $CollisionShape2D
onready var anim_player = $AnimationPlayer

func _ready():
	connect("body_entered", self, "_when_hit")
	connect("timeout", life_timer, "_on_LifeTimer_timeout")


func prepare(init_pos, init_vel, col_exception_body=null):
	if col_exception_body:
		#faction = col_exception_body.faction
		col_exceptions.append(col_exception_body)
	
	position = init_pos
	vel = init_vel
	
	#look_at(init_pos + vel)


func _physics_process(delta):
	if not hit:
		position += vel * delta


func _when_hit(body):
	# If the body is in collision exceptions.
	if body in col_exceptions: return
	
	# Prevent repetitive hitting
	if not hit:
		hit = true
		
		shape.call_deferred('set', 'disabled', true)
		
		anim_player.play("hit")
		
		# Make damage to the target.
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		# Stop moving
		vel = Vector2.ZERO


func _die():
	hide()
	call_deferred('queue_free')


func _on_LifeTimer_timeout():
	_die()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hit":
		_die()
