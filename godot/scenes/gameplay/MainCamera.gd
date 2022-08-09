extends Camera2D

# State
enum STATES { FOLLOW = 0, FOCUS, FREE, INACTIVE }
export (int) var state = 0 setget set_state

# For FOLLOW mode
var follow_target = null
export (NodePath) var follow_target_path = null

# For FOCUS mode
var focus_pos = Vector2.ZERO

# For FREE mode
var max_zoom = 4.0
var min_zoom = 0.2
var target_zoom = 1.0
var zoom_speed = 5.0

# Shaking mode
var is_shaking = false
var shake_amount = 1.0

# Touch screen variables
var touch_points = []


func _ready():
	Global.current_camera = self
	
	set_state(state)
	
	target_zoom = zoom.x


func _physics_process(delta):
	# Lerp zoom
	zoom = Vector2.ONE * lerp(zoom.x, target_zoom, zoom_speed * delta)
	
	match state:
		STATES.FOLLOW:
			if is_instance_valid(follow_target):
				set_position(follow_target.get_position())
				
				# Change offset according to movement direction (may cause inormal movement of ParallaxLayer)
#				if not is_shaking:
#					var offset_target = 0.0
#					if Input.is_action_pressed('ui_left'):
#						offset_target = -1.0
#					if Input.is_action_pressed('ui_right'):
#						offset_target = 1.0
#					offset_h = lerp(offset_h, offset_target, delta*0.4)
#
#					offset_target = 0.0
#					if Input.is_action_pressed('ui_up'):
#						offset_target = -1.0
#					if Input.is_action_pressed('ui_down'):
#						offset_target = 1.0
#					offset_v = lerp(offset_v, offset_target, delta*0.4)
		STATES.FOCUS:
			pass
		STATES.FREE:
			pass
	
	# Shake
	if is_shaking:
		set_offset(Vector2(rand_range(-1.0, 1.0) * shake_amount,\
			rand_range(-1.0, 1.0) * shake_amount))


func _input(event):
	# Not controllable
	#if Global.mouse_on_gui: return
	match state:
		STATES.FOLLOW:
			pass
		STATES.FOCUS:
			pass
		STATES.FREE:
			pass
#			if event is InputEventMouseButton:
#				if event.button_index == BUTTON_WHEEL_UP:
#					target_zoom -= 0.1
#				elif event.button_index == BUTTON_WHEEL_DOWN:
#					target_zoom += 0.1
#
#				target_zoom = clamp(target_zoom, min_zoom, max_zoom)
#
#			if event is InputEventMouseMotion:
#				if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
#					position -= event.relative * zoom.x
			
	_limit_camera_position()


func _limit_camera_position():
	global_position.x = clamp(global_position.x, limit_left + get_viewport().size.x / 2 * zoom.x, limit_right - get_viewport().size.x / 2 * zoom.x)
	global_position.y = clamp(global_position.y, limit_top + get_viewport().size.y / 2 * zoom.x, limit_bottom - get_viewport().size.y / 2 * zoom.x)


func set_limits(limit_rect):
	limit_left = limit_rect.position.x
	limit_top = limit_rect.position.x
	limit_right = limit_rect.end.x
	limit_bottom = limit_rect.end.y


func shake(time):
	if is_shaking: return
	$ShakeTimer.wait_time = time
	$ShakeTimer.start()
	is_shaking = true


func _on_ShakeTimer_timeout():
	is_shaking = false
	set_offset(Vector2.ZERO)


func set_state(new_state):
	match new_state:
		STATES.FOLLOW:
			state = new_state
			drag_margin_h_enabled = true
			drag_margin_v_enabled = true
			
			# For smooth transition
			smoothing_enabled = false
			
			if follow_target_path:
				follow_target = get_node_or_null(follow_target_path)
		STATES.FOCUS:
			state = new_state
			drag_margin_h_enabled = false
			drag_margin_v_enabled = false
			
			smoothing_enabled = true
			
			set_global_position(focus_pos)
		STATES.FREE:
			state = new_state
			drag_margin_h_enabled = false
			drag_margin_v_enabled = false
			
			# For responsive camera pan
			smoothing_enabled = false
		STATES.INACTIVE:
			state = new_state
			current = false
