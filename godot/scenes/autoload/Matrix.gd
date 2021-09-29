extends Node


func xnew(rows : int, cols : int):
	var mat = []
	
	for i in range(rows):
		var row = []
		row.resize(cols)
		mat.append(row)
	
	return mat


func xcopy(mat):
	var new_mat = xnew(mat.size(), mat[0].size())
	
	for i in range(mat.size()):
		for j in range(mat[0].size()):
			new_mat[i][j] = mat[i][j]
	
	return new_mat


func xset_zero(mat):
	for i in range(mat.size()):
		for j in range(mat[0].size()):
			# Zero indicates being empty
			mat[i][j] = 0


func xrandomize(mat, max_value):
	# New seed
	randomize()
	
	for i in range(mat.size()):
		for j in range(mat[0].size()):
			mat[i][j] = randi() % max_value + 1
