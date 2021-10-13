extends TextureRect
class_name AnimatedTextureRect
tool

export (Texture) var atlas setget set_atlas
export (int, 1, 100) var h_frames := 4 setget set_h_frames
export (int, 1, 100) var v_frames := 4 setget set_v_frames
export (int, 0, 100) var current_frame := 0 setget set_frame
export (int) var fps = 5 setget set_fps
export (bool) var oneshot = false
export (bool) var playing = false

var play_direction = 1
var anim_tex = AnimatedTexture.new()

var last_time : int

signal animation_finished
signal animation_finished_backwards


func set_atlas(p_atlas):
	atlas = p_atlas
	
	_reload_atlas()


func set_h_frames(p_h_frames):
	h_frames = p_h_frames
	
	_reload_atlas()


func set_v_frames(p_v_frames):
	v_frames = p_v_frames
	
	_reload_atlas()


func set_frame(p_frame):
	anim_tex.current_frame = clamp(p_frame, 0, anim_tex.frames - 1)
	current_frame = anim_tex.current_frame


func _reload_atlas():
	if not atlas: return
	
	# Single sheet
	# Do not use Image.new() and Image.load() to create an Image
	# Otherwise it won't work on export, use this instead
	var img = atlas.get_data()
	
	var size = img.get_size()
	var frame_size = size / Vector2(h_frames, v_frames)
	
	for frame in range(h_frames * v_frames):
		var frame_pos = Vector2(frame % h_frames, floor(float(frame) / h_frames))
		
		var itex = ImageTexture.new()
		itex.create_from_image(img.get_rect(Rect2(frame_size * frame_pos, frame_size)))
		
		anim_tex.set_frame_texture(frame, itex)
	
	anim_tex.frames = h_frames * v_frames
	####################################
	
	anim_tex.pause = true
	texture = anim_tex
	
	last_time = OS.get_ticks_msec()


func set_fps(new_fps):
	fps = clamp(new_fps, 0, 200)


func _process(delta):
	if fps == 0: return
	
	if OS.get_ticks_msec() - last_time > 1000.0 / fps and playing:
		# Do this before updating the frame,
		# otherwise the last/first frame wouldn't show
		if play_direction == -1 and anim_tex.current_frame == 0:
			if oneshot:
				emit_signal("animation_finished_backwards")
			else:
				anim_tex.current_frame = anim_tex.frames - 1
		elif play_direction == 1 and anim_tex.current_frame == anim_tex.frames - 1:
			if oneshot:
				emit_signal("animation_finished")
			else:
				anim_tex.current_frame = 0
		
		# Animation progress
		anim_tex.current_frame = clamp(anim_tex.current_frame + play_direction, 0, anim_tex.frames - 1)
		last_time = OS.get_ticks_msec()
