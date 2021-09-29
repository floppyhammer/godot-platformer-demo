extends TextureButton


func _ready():
	connect("pressed", self, "_when_pressed")
	connect("item_rect_changed", self, "_when_item_rect_changed")
	
	rect_scale = Vector2.ONE
	
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	_when_item_rect_changed()


func _when_pressed():
	$AnimPlayer.play("pressed")
	$PressSound.play()


func _when_item_rect_changed():
	rect_pivot_offset = rect_size / 2
