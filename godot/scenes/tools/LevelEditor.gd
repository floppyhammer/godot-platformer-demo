extends Panel

var level_name = ""
var level_config = {
	"matrix": null,
	"steps": null,
	"score": null,
	"items": null,
	"criterion": null,
}
var block_mat
var state_mat
const ROWS = 6
const COLS = 6
var block_size = 100
var block_scene = load("res://scenes/gameplay/Block.tscn")

onready var grid = $MarginC/VBoxC/CenterC/PanelC/MarginC/GridC
onready var list = $MarginC/VBoxC/ItemList
onready var blocks = $MarginC/VBoxC/CenterC/PanelC/Blocks
onready var name_edit = $MarginC/VBoxC/HBoxC2/NameLineEdit
onready var step_spinbox = $MarginC/VBoxC/HBoxC3/StepSpinBox
onready var score_spinbox = $MarginC/VBoxC/HBoxC3/ScoreSpinBox


func _ready():
	OS.window_size = Vector2(480, 640)
	level_config["score"] = 10
	level_config["steps"] = 10
	level_config["items"] = [0, 0, 0, 0]
	level_config["criterion"] = [0, 0, 0]
	
	_initialize_blocks()
	
	$Level.set_process_input(false)
	$Level.is_testing = true
	$Level.get_node("BGM").stop()
	
	block_mat = Math.create_mat(ROWS, COLS)
	Math.initialize_mat(block_mat)
	
	state_mat = Math.create_mat(ROWS, COLS)
	Math.initialize_mat(state_mat)
	
	_adapt_to_window()
	
	_reload_list()


func _process(delta):
	update()


func _reload_list():
	list.clear()
	list.add_icon_item(ResourceLoader.load("res://assets/blocks/0.png"))
	list.set_item_metadata(0, {"id": 0})
	
	for key in Global.block_db:
		var tex = ResourceLoader.load(Global.block_db[key]["texture"])
		list.add_icon_item(tex)
		list.set_item_metadata(list.get_item_count() - 1, {"id": int(key)})


func _initialize_blocks():
	for i in range(ROWS):
		for j in range(COLS):
			var index = i * COLS + j
			var new_block = block_scene.instance()
			new_block.show()
			blocks.add_child(new_block)


func _input(event):
	if not (event is InputEventScreenTouch or event is InputEventMouse):
		return
	
	if $Level.visible:
		return
	
	# Global mouse position
	var mouse_pos = event.position - grid.get_parent().rect_global_position
	
	# Outside of the grid
	if not (mouse_pos.x > 0 and mouse_pos.y > 0):
		return
	
	# Touched matrix element
	var col = int(mouse_pos.x / block_size)
	var row = int(mouse_pos.y / block_size)
	
	if row >= ROWS or col >= COLS:
		return
	
	# Add blocks
	if event is InputEventScreenTouch and not event.is_pressed():
		if list.get_selected_items().size() > 0:
			var selected = list.get_selected_items()[0]
			var id = list.get_item_metadata(selected)["id"]
			
			if id != -1:
				block_mat[row][col] = id
				
				print("Add block to %d,%d" % [row, col])
				
				if id == 0:
					state_mat[row][col] = 0
			else:
				state_mat[row][col] = id
				print("Add state to %d,%d" % [row, col])


func _draw():
	# Base grid
	for i in range(ROWS):
		for j in range(COLS):
			var c = Color.white
			if list.get_selected_items().size() > 0:
				if block_mat[i][j] == 0:
					c = Color.green
			grid.get_child(i * COLS + j).modulate = c
	
	# Draw blocks
	for i in range(ROWS):
		for j in range(COLS):
			var block_node = blocks.get_child(i * COLS + j)
			var block_id = block_mat[i][j]
			var state_id = state_mat[i][j]
			
			block_node.update_looking(block_id, state_id == -1)
			
			if block_id == 0:
				block_node.texture = null
			else:
				block_node.texture = load("res://assets/blocks/%d.png" % block_id)
			block_node.get_node("ID").text = str(block_id)
			
			if block_id <= 0:
				block_node.get_node("ID").text = ""


func _on_LevelEditor_item_rect_changed():
	var square_size = min($MarginC/VBoxC/CenterC.rect_size.x, $MarginC/VBoxC/CenterC.rect_size.y)
	$MarginC/VBoxC/CenterC/PanelC.rect_min_size = Vector2.ONE * square_size
	call_deferred("_adapt_to_window")


func _adapt_to_window():
	# Adaptive size of blocks
	block_size = int(round(grid.get_parent().rect_size.x / COLS))
	
	for i in range(ROWS):
		for j in range(COLS):
			var index = i * COLS + j
			var block = blocks.get_child(index)
			block.rect_position = get_block_rect(i, j).position
			block.rect_size = get_block_rect(i, j).size
			block.rect_pivot_offset = block.rect_size / 2


func get_block_pos(row : int, col : int) -> Vector2:
	return Vector2(col, row) * block_size


func get_block_center_pos(row : int, col : int) -> Vector2:
	return Vector2(col, row) * block_size + Vector2.ONE * block_size * 0.5


func get_block_rect(row : int, col : int) -> Rect2:
	# Without margin
	#return Rect2(get_block_pos(row, col) + Vector2.ONE * MARGIN, Vector2.ONE * size - Vector2.ONE * MARGIN * 2)
	
	# With margin
	return Rect2(get_block_pos(row, col), Vector2.ONE * block_size)


func _on_Play_pressed():
	level_config["matrix"] = Math.duplicate_mat(block_mat)
	level_config["state_matrix"] = Math.duplicate_mat(state_mat)
	
	# print(level_config)
	
	# Transition
	$Level.show()
	$Level.set_process_input(true)
	$Level.prepare(level_name, level_config)


func _on_Save_pressed():
	level_name = name_edit.placeholder_text
	if name_edit.text != "":
		level_name = name_edit.text
	
	save_level()


func save_level():
	level_config["matrix"] = block_mat
	level_config["state_matrix"] = state_mat
	JsonParser.write_data("user://%s.json" % level_name, level_config)
	$Prompt/Label.text = "关卡已保存"
	$Prompt/Tween.interpolate_property($Prompt, "modulate", Color.transparent, Color.white, 0.5)
	$Prompt/Tween.interpolate_property($Prompt, "modulate", Color.white, Color.transparent, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1)
	$Prompt/Tween.start()


func _on_Clear_pressed():
	Math.initialize_mat(block_mat)
	Math.initialize_mat(state_mat)


func _on_OverwriteAlert_confirmed():
	save_level()


func _on_NameLineEdit_text_changed(new_text):
	level_name = name_edit.placeholder_text


func _on_StepSpinBox_value_changed(value):
	level_config["steps"] = int(value)


func _on_ScoreSpinBox_value_changed(value):
	level_config["score"] = int(value)


func _on_SavePath_pressed():
	OS.shell_open(OS.get_user_data_dir())


func _on_StarEdit_text_changed(new_text):
	level_config["criterion"] = new_text.split_floats(',')


func _on_ItemEdit_text_changed(new_text):
	level_config["items"] = new_text.split_floats(',')
