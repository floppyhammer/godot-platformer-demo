extends TextureButton

export var tab_label = ""


func _ready():
	rect_pivot_offset = rect_size / 2
	
	$Label.text = tab_label
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED


func _on_CustomTextureButton_pressed():
	$AnimPlayer.play("pressed")


func _on_CustomTextureButton_item_rect_changed():
	rect_pivot_offset = rect_size / 2


func _on_TabButton_toggled(button_pressed):
	if button_pressed:
		$Label.set("custom_colors/font_outline_modulate", Color("00b0dc"))
	else:
		$Label.set("custom_colors/font_outline_modulate", Color("7f7f7f"))
