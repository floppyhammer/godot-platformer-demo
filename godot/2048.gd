extends Node

var ROWS = 6
var COLS = 6
var block_mat : Array


func _ready():
	block_mat = Matrix.xnew(ROWS, COLS)


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
					$Blocks.get_child(which_child).merge(des)
				elif moving_type[k] == 1:
					$Blocks.get_child(which_child).merge_2(des)
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
	
	_reset_block_positions()
