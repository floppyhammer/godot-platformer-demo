extends TextureButton

export var text = ""
export (bool) var is_in_level = true


func _ready():
	rect_pivot_offset = rect_size / 2
	
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	$DescriptionLabel.hide()
	$DescriptionLabel.bbcode_text = Global.item_db["BOMB"]["description_%s" % TranslationServer.get_locale()]


func _on_CustomTextureButton_pressed():
	$AnimationPlayer.play("pressed")
	$Touch.play()


func _on_CustomTextureButton_item_rect_changed():
	rect_pivot_offset = rect_size / 2


func _on_ButtonItem_pressed():
	disabled = true
	
	var level = get_node_or_null("/root/Main/Content/Level")
	if not level:
		level = get_node_or_null("/root/Level")
	
	level.play_grid.is_using_item = true
	level.play_grid.connect("item_target_selected", self, "_when_target_selected")


func _when_target_selected(row, col):
	var level = get_node_or_null("/root/Main/Content/Level")
	if not level:
		level = get_node_or_null("/root/Level")
	
	if level.play_grid.block_mat[row][col] == 0:
		level.play_grid.add_block_queue(row, col, -3)
	
		queue_free()


func _on_ButtonItem_button_down():
	$DescriptionLabel.show()


func _on_ButtonItem_button_up():
	$DescriptionLabel.hide()
