extends Control

export (Texture) var texture
export (int, 1, 100) var h_frames := 1
export (int, 1, 100) var v_frames := 1
export (int) var fps = 30
export (bool) var debug = false

var anim_tex = AnimatedTexture.new()

var play_direction = 1

signal appeared
signal disappeared


func _ready():
	# Seperated textures
#	var total_frames = 16
#	for i in range(total_frames):
#		anim_tex.set_frame_texture(i, load("res://assets/vfx/transition/transition%d.png" % (i + 1)))
#	anim_tex.frames = total_frames
	#################################
	
	# Single sheet
	# Do not use Image.new() and Image.load() to create an Image
	# Otherwise it won't work on export, use this instead
	if not texture: return
	var img = texture.get_data()
	
	var size = img.get_size()
	var frame_size = size / Vector2(h_frames, v_frames)
	
	for frame in range(h_frames * v_frames):
		var frame_pos = Vector2(frame % h_frames, floor(float(frame) / h_frames))
		
		var itex = ImageTexture.new()
		itex.create_from_image(img.get_rect(Rect2(frame_size * frame_pos, frame_size)))
		
		anim_tex.set_frame_texture(frame, itex)
	
	anim_tex.frames = h_frames * v_frames
	####################################
	
	$FpsTimer.wait_time = 1.0 / fps
	anim_tex.oneshot = true
	anim_tex.pause = true
	$TextureRect.texture = anim_tex


# Test
func _input(event):
	if debug:
		if event is InputEventMouseButton:
			if event.pressed:
				if event.button_index == BUTTON_LEFT:
					disappear()
				elif event.button_index == BUTTON_RIGHT:
					appear()


func disappear():
	anim_tex.current_frame = 0
	play_direction = 1
	$FpsTimer.start()


func appear():
	show()
	anim_tex.current_frame = anim_tex.frames - 1
	play_direction = -1
	$FpsTimer.start()


func _on_FpsTimer_timeout():
	# Do this before updating the frame,
	# otherwise the last/first frame wouldn't show.
	if play_direction == -1 and anim_tex.current_frame == 0:
		$FpsTimer.stop()
		emit_signal("appeared")
	elif play_direction == 1 and anim_tex.current_frame == anim_tex.frames - 1:
		$FpsTimer.stop()
		hide()
		emit_signal("disappeared")
	
	# Animation progress
	anim_tex.current_frame = clamp(anim_tex.current_frame + play_direction, 0, anim_tex.frames - 1)
