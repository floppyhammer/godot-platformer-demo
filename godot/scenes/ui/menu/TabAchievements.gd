extends MarginContainer

var current_page = 0
var total_pages = 0
var total_no = 0
var discovered_no = 0
var no_per_page = 12
var text2show = ""
var db_key_list = []

onready var grid = $ScrollC/GridC


func _ready():
	reset()


func reset():
	current_page = 0
	#_reload()


func load_last():
	current_page -= 1
	_reload()


func load_next():
	current_page += 1
	_reload()


func _reload():
	total_no = 0
	discovered_no = 0
	
	var db = Global.block_db
	var progress = Global.block_progress
	
	db_key_list.clear()
	for key in db:
		total_no += 1
		db_key_list.append(key)
		if progress[key]["discovered"]:
			discovered_no += 1
	
	total_pages = int(ceil(total_no / float(no_per_page)))
	
	current_page = clamp(current_page, 0, total_pages - 1)
	
	for i in grid.get_child_count():
		var list_index = current_page * no_per_page + i
		
		var key = "null"
		if list_index < db_key_list.size():
			key = db_key_list[list_index]
		
		var child = grid.get_child(i)
		
		if db.has(key):
			child.texture_normal = load(db[key]["texture"])
		else:
			child.texture_normal = null
		
		# Update looking depending on if discovered
		if progress.has(key):
			if progress[key]["discovered"]:
				child.self_modulate = Color("ffffff")
			else:
				child.self_modulate = Color("000000")
	
	# Update progress label
	text2show = tr("BLOCK_COLLECTION_PROGRESS") % [discovered_no, total_no]
	
	return
