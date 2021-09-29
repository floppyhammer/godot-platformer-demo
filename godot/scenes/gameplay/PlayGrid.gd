extends PanelContainer

# Block grid
var ROWS = 6
var COLS = 6
var block_mat : Array
var size = 100

var popup_score_scene = load("res://scenes/ui/PopupScore.tscn")
var block_scene = load("res://scenes/gameplay/Block.tscn")

# Which blocks will be affected if tapping on the current position
var blocks_affected = []

# Blocks on hand
var blocks_on_hand = []
var max_blocks_on_hand = 1

# Block sprites
var sprites = []

# Score
var score = 0

# When the last valid operation occurred
var last_time_operated = -1

var initial_blocks = []

var falling_timer_ratio = 1.0

onready var blocks_parent = $Blocks
var is_using_item = false

var block_adding_queue = []

signal block_created
signal just_operated
signal reached_bottom
signal hand_is_full
signal assessment_changed
signal item_target_selected


func _ready():
	connect("item_rect_changed", self, "_adapt_to_window")
	#connect("gui_input", self, "_deal_with_local_input")
	
	# Create block matrix.
	block_mat = Matrix.xnew(ROWS, COLS)
	Matrix.xset_zero(block_mat)
	
	# Add blocks.
	_add_blocks()
	
	# Adapt to window size.
	_adapt_to_window()
	
	# Set block positions.
	_reset_blocks()


func move_left():
	for i in range(ROWS):
		var row = []
		var moving_start = []
		var moving_end = []
		var moving_type = []
		
		# Remove all zeros
		for j in range(COLS):
			if block_mat[i][j] != 0:
				moving_end.append(moving_start.size())
				moving_start.append(j)
				moving_type.append(0)
				
				row.append(block_mat[i][j])
			block_mat[i][j] = 0
		
		# Merge block pairs (same loop for directions)
		for k in range(1, row.size()):
			if row[k] == row[k-1]:
				moving_end[k] = moving_end[k-1]
				row[k-1] += 1
				row[k] = 0
		
		# Remove zeros again
		var new_row = []

		var zero_count = 0
		for k in range(row.size()):
			moving_end[k] -= zero_count
			if row[k] != 0:
				new_row.append(row[k])
			else:
				# Merge happened
				moving_type[k] = 1
				
				zero_count += 1

		row = new_row
		
		# Apply back to the matrix
		for k in range(row.size()):
			block_mat[i][k] = row[k]
		
		# Animations
		for k in range(moving_start.size()):
			# If start and end positions are different
			if moving_start[k] != moving_end[k]:
				var block_y = moving_start[k]
				var which_child = i * COLS + block_y
				var des = get_block_pos(i, moving_end[k])
				if moving_type[k] == 0:
					blocks_parent.get_child(which_child).merge(des)
				elif moving_type[k] == 1:
					blocks_parent.get_child(which_child).merge_2(des)
	return


func move_right():
	for i in range(ROWS):
		var row = []
		var moving_start = []
		var moving_end = []
		var moving_type = []
		
		# Remove all zeros
		for j in range(COLS-1, -1, -1):
			if block_mat[i][j] != 0:
				moving_end.append(moving_start.size())
				moving_start.append(j)
				moving_type.append(0)
				row.append(block_mat[i][j])
			block_mat[i][j] = 0
		
		# Merge block pairs (same for directions)
		for k in range(1, row.size()):
			if row[k] == row[k-1]:
				moving_end[k] = moving_end[k-1]
				row[k-1] += 1
				row[k] = 0

		# Remove zeros again (same for directions)
		var new_row = []
		var zero_count = 0
		for k in range(row.size()):
			moving_end[k] -= zero_count
			if row[k] != 0:
				new_row.append(row[k])
			else:
				# Merge happened
				moving_type[k] = 1
				
				zero_count += 1
		
		# Replace old row
		row = new_row
		
		# Apply changes back to the matrix
		for k in range(row.size()):
			block_mat[i][-1-k] = row[k]
		
		# Animations
		for k in range(moving_start.size()):
			# If start and end positions are different
			if moving_start[k] != (COLS - 1 - moving_end[k]):
				var block_y = moving_start[k]
				var which_child = i * COLS + block_y
				var des = get_block_pos(i, COLS - 1 - moving_end[k])
				
				if moving_type[k] == 0:
					$Blocks.get_child(which_child).merge(des)
				elif moving_type[k] == 1:
					$Blocks.get_child(which_child).merge_2(des)
	return


func move_up():
	for i in range(COLS):
		var col = []
		var moving_start = []
		var moving_end = []
		var moving_type = []
		
		# Remove all zeros
		for j in range(ROWS):
			if block_mat[j][i] != 0:
				col.append(block_mat[j][i])
				moving_end.append(moving_start.size())
				moving_start.append(j)
				moving_type.append(0)
			block_mat[j][i] = 0
		
		# Merge block pairs (same loop for directions)
		for k in range(1, col.size()):
			if col[k] == col[k-1]:
				moving_end[k] = moving_end[k-1]
				col[k-1] += 1
				col[k] = 0

		# Remove zeros again
		var new_col = []
		var zero_count = 0
		for k in range(col.size()):
			moving_end[k] -= zero_count
			if col[k] != 0:
				new_col.append(col[k])
			else:
				# Merge happened
				moving_type[k] = 1
				zero_count += 1
		
		# Replace
		col = new_col
		
		# Apply back to the matrix
		for k in range(col.size()):
			block_mat[k][i] = col[k]
		
		# Animations
		for k in range(moving_start.size()):
			# If start and end positions are different
			if moving_start[k] != moving_end[k]:
				var block_x = moving_start[k]
				var which_child = block_x * COLS + i
				var des = get_block_pos(moving_end[k], i)
				if moving_type[k] == 0:
					$Blocks.get_child(which_child).merge(des)
				elif moving_type[k] == 1:
					$Blocks.get_child(which_child).merge_2(des)
	return


func move_down():
	for i in range(COLS):
		var col = []
		var moving_start = []
		var moving_end = []
		var moving_type = []
		
		# Remove all zeros
		for j in range(ROWS-1, -1, -1):
			if block_mat[j][i] != 0:
				col.append(block_mat[j][i])
				moving_end.append(moving_start.size())
				moving_start.append(j)
				moving_type.append(0)
			block_mat[j][i] = 0
		
		# Merge block pairs (same loop for directions)
		for k in range(1, col.size()):
			if col[k] == col[k-1]:
				moving_end[k] = moving_end[k-1]
				col[k-1] += 1
				col[k] = 0

		# Remove zeros again
		var new_col = []
		var zero_count = 0
		for k in range(col.size()):
			moving_end[k] -= zero_count
			if col[k] != 0:
				new_col.append(col[k])
			else:
				# Merge happened
				moving_type[k] = 1
				zero_count += 1
		col = new_col
		
		# Apply back to the matrix
		for k in range(col.size()):
			block_mat[-1-k][i] = col[k]
			
		# Animations
		for k in range(moving_start.size()):
			# If start and end positions are different
			if moving_start[k] != (ROWS - 1 - moving_end[k]):
				var block_x = moving_start[k]
				var which_child = block_x * COLS + i
				var des = get_block_pos(ROWS - 1 - moving_end[k], i)
				if moving_type[k] == 0:
					$Blocks.get_child(which_child).merge(des)
				elif moving_type[k] == 1:
					$Blocks.get_child(which_child).merge_2(des)
	return


func _input(event):
	# Interval for animation between operations.
	if not $AnimTimer.is_stopped(): return
	
	if Input.is_action_just_pressed("ui_up"):
		move_up()
	if Input.is_action_just_pressed("ui_down"):
		move_down()
	if Input.is_action_just_pressed("ui_left"):
		move_left()
	if Input.is_action_just_pressed("ui_right"):
		move_right()
	
	$AnimTimer.start()
	yield($AnimTimer, "timeout")
	
	# Set final positions after animations.
	_reset_blocks()


func _add_blocks():
	for i in range(ROWS):
		for j in range(COLS):
			var index = i * COLS + j
			var new_block = block_scene.instance()
			blocks_parent.add_child(new_block)
	return


func _reset_blocks():
	for i in range(ROWS):
		for j in range(COLS):
			var index = i * COLS + j
			var block_id = int(block_mat[i][j])
			blocks_parent.get_child(index).update_looking(block_id)
			blocks_parent.get_child(index).rect_position = get_block_rect(i, j).position
			blocks_parent.get_child(index).rect_size = get_block_rect(i, j).size
			blocks_parent.get_child(index).rect_rotation = 0
			blocks_parent.get_child(index).rect_scale = Vector2.ONE
			blocks_parent.get_child(index).rect_pivot_offset = $Blocks.get_child(index).rect_size * 0.5
			
			# Update block progress
			if Global.block_progress.has("block %d" % block_id):
				Global.block_progress["block %d" % block_id]["discovered"] = true
	return


func reset_level(block_mat_in):
	# Deep copy the block matrix
	block_mat = Matrix.xcopy(block_mat_in)
	
	# Initial blocks for later random generation
	initial_blocks.clear()
	for i in range(ROWS):
		for j in range(COLS):
			if block_mat[i][j] != 0 and not block_mat[i][j] in initial_blocks:
				initial_blocks.append(block_mat[i][j])
	
	# Reset level
	$Tween.remove_all()
	
	_reset_blocks()


func _deal_with_local_input(event):
#	if get_tree().paused: return
#
#	if not (event is InputEventScreenTouch or event is InputEventMouseButton):
#		return
#
#	# Cannot operate when animations are playing
#	if not $AnimTimer.is_stopped(): return
#
#	if $Tween.is_active(): return
#
#	# Local tap position
#	var tap_pos = event.position
#
#	# Beyond the left and top boundaries of the grid
#	if not (tap_pos.x > 0 and tap_pos.y > 0):
#		return
#
#	# Matrix coordinate of the click position
#	var col = int(tap_pos.x / size)
#	var row = int(tap_pos.y / size)
#
#	# Clear affected blocks
#	blocks_affected.clear()
#
#	# Valid operation area
#	if 0 <= col and col < COLS and 0 <= row and row < ROWS:
#		if is_using_item:
#			emit_signal("item_target_selected", row, col)
#			is_using_item = false
#			return
#
#		# Add affected blocks
#		for i in range(ROWS - 1, row - 1, -1):
#			# If not the bottom block in the continuous column
#			if blocks_affected.size() > 0:
#				break
##				if block_mat[i][col] == block_mat[blocks_affected[0].x][blocks_affected[0].y]:
##					blocks_affected.append(Vector2(i, col))
##				# Differect block encountered, interrupting the continuous column
##				else:
##					break
#			# Bottom block in the continuous column
#			elif block_mat[i][col] != 0:
#				blocks_affected.append(Vector2(i, col))
#
#	# Affect the blocks
#	if blocks_affected.size() > 0:
#		if event is InputEventScreenTouch and event.is_pressed():
#			# Which block
#			var block_id = int(block_mat[blocks_affected[0].x][blocks_affected[0].y])
#
#			# Non-selectable blocks
#			if Global.block_db["block %d" % block_id].has("grabbable"):
#				if not Global.block_db["block %d" % block_id]["grabbable"]:
#					$UngrabbableAlert.play()
#					return
#
#			# If hand is full and the next block is different from the top block on hand
#			# Or if affected blocks are continuous, which means in situ elimination is possible
#			if blocks_on_hand.size() >= max_blocks_on_hand:
#				if block_id != blocks_on_hand[0] and blocks_affected.size() < 2:
#					$FullHandAlert.play()
#					print("Hand is full")
#					emit_signal("hand_is_full")
#					return
#
#			# Record op time
#			last_time_operated = OS.get_ticks_msec()
#
#			# Top block in the continuous column
#			var top_block_row = blocks_affected[-1].x
#			var top_block_col = blocks_affected[-1].y
#			var top_block_affected_pos = get_block_center_pos(top_block_row, top_block_col)
#			var top_block_affected_rect_pos = get_block_pos(top_block_row, top_block_col)
#
#			# Decide op type
#			var op_type = ""
#			var blocks_merged = 0
#			# Merge
#			if blocks_affected.size() > 1:
#				# Merge x on grid with 1 on hand
#				if blocks_on_hand.size() > 0 and block_id == blocks_on_hand[0]:
#					op_type = "merge x on grid with 1 on hand"
#					blocks_merged = blocks_affected.size() + 1
#				else:
#					op_type = "merge x on grid"
#					blocks_merged = blocks_affected.size()
#			else:
#				# Merge 1 on grid with 1 on hand
#				if blocks_on_hand.size() > 0 and block_id == blocks_on_hand[0]:
#					op_type = "merge 1 on grid with 1 on hand"
#					blocks_merged = blocks_affected.size() + 1
#				# Pick
#				else:
#					op_type = "pick"
#
#					if block_id == -2:
#						op_type = "special"
#
#			########### Play animations for the operation ##############
#			# Move the stick
#			var merge_stick_block = false
#			if op_type in ["merge x on grid with 1 on hand", "merge 1 on grid with 1 on hand"]:
#				merge_stick_block = true
#
#			var op_score = 0
#
#			if op_type in [
#				"merge x on grid with 1 on hand",
#				"merge x on grid",
#				"merge 1 on grid with 1 on hand",
#				"special"
#				]:
#
#				for block in blocks_affected:
#					var which_child = block.x * COLS + block.y
#					$Blocks.get_child(which_child).merge(top_block_affected_rect_pos)
#				if (block_id + 1) % 3 == 0:
#					var popup_score_label = popup_score_scene.instance()
#					$Blocks.add_child(popup_score_label)
#					popup_score_label.prepare(3, top_block_affected_pos)
#			elif op_type == "pick":
#				for block in blocks_affected:
#					var which_child = block.x * COLS + block.y
#					$Blocks.get_child(which_child).pick()
#
#			$AnimTimer.start()
#			yield($AnimTimer, "timeout")
#			_reset_blocks()
#			###########################################
#
#			# Record valid operation
#			emit_signal("just_operated")
#
#			# WAIT for the anims to finish, then remove affected blocks from grid to hand
#			if op_type in ["merge x on grid with 1 on hand", "merge 1 on grid with 1 on hand"]:
#				# Remove blocks both on hand and on grid
#				for block in blocks_affected:
#					var which_child = block.x * COLS + block.y
#					blocks_on_hand.pop_front()
#					block_mat[block.x][block.y] = 0
#
#				# Add to grid with an increased block ID
#				var new_block_id = block_id + 1
#				if new_block_id % 3 == 0:
#					score += 3
#					# Consume block
#					block_mat[top_block_row][top_block_col] = 0
#				else:
#					# Upgrade block
#					block_mat[top_block_row][top_block_col] = new_block_id
#				var new_block_center_pos = get_block_center_pos(top_block_row, top_block_col) + rect_global_position
#
#				emit_signal("block_created", new_block_id, new_block_center_pos)
#			elif op_type == "merge x on grid":
#				# Remove blocks on grid
#				for block in blocks_affected:
#					var which_child = block.x * COLS + block.y
#					block_mat[block.x][block.y] = 0
#
#				# Add to grid with an increased block ID
#				block_mat[top_block_row][top_block_col] = block_id + 1
#
#				var new_block_center_pos = get_block_center_pos(top_block_row, top_block_col) + rect_global_position
#
#				emit_signal("block_created", block_id + 1, new_block_center_pos)
#			elif op_type == "pick":
#				for block in blocks_affected:
#					blocks_on_hand.push_front(block_id)
#					block_mat[block.x][block.y] = 0
#
#			elif op_type == "special":
#				for block in blocks_affected:
#					var which_child = block.x * COLS + block.y
#					block_mat[block.x][block.y] = 0
#
#			# Restore block looking
#			_reset_blocks()
#
#			# Clear visual indicator for afftect blocks
#			blocks_affected.clear()
	return


func get_block_pos(row : int, col : int) -> Vector2:
	return Vector2(col, row) * size


func get_block_center_pos(row : int, col : int) -> Vector2:
	return Vector2(col, row) * size + Vector2.ONE * size * 0.5


func get_block_rect(row : int, col : int) -> Rect2:
	# Without margin
	#return Rect2(get_block_pos(row, col) + Vector2.ONE * MARGIN, Vector2.ONE * size - Vector2.ONE * MARGIN * 2)
	
	# With margin
	return Rect2(get_block_pos(row, col), Vector2.ONE * size)


# Shuffle blocks in situ
func shuffle_grid():
	Logger.info("Shuffled grid", "Level")
	
	# Put blocks into an array
	var valid_blocks = []
	var original_coord = []
	for i in range(ROWS):
		for j in range(COLS):
			if block_mat[i][j] > 0:
				valid_blocks.append(block_mat[i][j])
				original_coord.append([i, j])
	
	# Shuffle blocks in the array
	valid_blocks.shuffle()
	
	# Put shuffled blocks back to the original coordinates
	for k in range(original_coord.size()):
		block_mat[original_coord[k][0]][original_coord[k][1]] = valid_blocks[k]
	
	_reset_blocks()
	
	return


func remove_a_block(row, col):
	block_mat[row][col] = 0
	
	_reset_blocks()


# Item operation
func shovel_grid_bottom():
	# Remove any food blocks in the last two rows
	for j in range(COLS):
		for i in range(ROWS - 1, ROWS - 3, -1):
			if block_mat[i][j] != 0:
				if block_mat[i][j] > 0:
					block_mat[i][j] = 0
				
				# Move on to the next column
				break
	
	_reset_blocks()
	
	return


# Make the play grid adaptive to the window size
func _adapt_to_window():
	# Keep aspect
	rect_min_size.y = rect_size.x
	
	# Adaptive size of blocks
	size = int(round(rect_min_size.y / ROWS))
	
	for i in range(ROWS):
		for j in range(COLS):
			var index = i * COLS + j
			var block = $Blocks.get_child(index)
			block.rect_position = get_block_rect(i, j).position
			block.rect_size = get_block_rect(i, j).size
			block.rect_pivot_offset = block.rect_size / 2
	
	return


func _get_block(row : int, col : int):
	var index = row * COLS + col
	
	return blocks_parent.get_child(index)


# Use a queue to avoid matrix operation disorder
func add_block_queue(row, col, block_id):
	block_mat[row][col] = block_id
	_reset_blocks()
	#block_adding_queue.append([row, col, block_id])
