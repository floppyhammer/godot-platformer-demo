extends MarginContainer

var current_page = 0
var total_pages = 0
var total_no = 0
var discovered_no = 0
var no_per_page = 12
var text2show = ""
var btn_group = ButtonGroup.new()

onready var grid = $ScrollC/GridC
onready var desc_panel = $InfoPanel
onready var description_label = $InfoPanel/Info


# Called when the node enters the scene tree for the first time.
func _ready():
	desc_panel.hide()
	
	for child in grid.get_children():
		child.group = btn_group
		child.connect("button_up", self, "_when_button_up")
		child.connect("button_down", self, "_when_button_down")
	
	reset()


func reset():
	current_page = 0
	_reload()


func _when_button_down():
	for i in range(grid.get_child_count()):
		if grid.get_child(i) == btn_group.get_pressed_button():
			var item_key = grid.get_child(i).get_node("Metadata").text
			if Global.item_db.has(item_key):
				description_label.bbcode_text = Global.item_db[item_key]["description_%s" % TranslationServer.get_locale()]
				desc_panel.show()


func _when_button_up():
	pass
	#description_label.hide()


func load_last():
	current_page -= 1
	current_page = clamp(current_page, 0, total_pages - 1)
	_reload()


func load_next():
	current_page += 1
	current_page = clamp(current_page, 0, total_pages - 1)
	_reload()
	

func _reload():
	total_no = 0
	discovered_no = 0
	
	var db = Global.item_db
	var progress = Global.item_progress
	
	# Do some statistics
	for key in db:
		if progress[key]["amount"] > 0:
			total_no += 1
	
	total_pages = int(ceil(total_no / float(no_per_page)))
	
	for child in grid.get_children():
		child.texture_normal = null
		child.get_node("Amount").show()
		child.get_node("Amount").text = ""
	
	var temp_no = 0
	var in_page_no = 0
	for key in progress:
		if progress[key]["amount"] > 0:
			if (current_page * no_per_page) <= temp_no and temp_no < ((current_page + 1) * no_per_page):
				var button = grid.get_child(in_page_no)
				button.texture_normal = load(db[key]["texture"])
				in_page_no += 1
				button.get_node("Metadata").text = key
				button.get_node("Amount").text = str(progress[key]["amount"])
				
			temp_no += 1

	# Update progress label
	text2show = str(total_no)
#
#	page_label.text = str(current_page + 1)
#
#	last_btn.disabled = false
#	next_btn.disabled = false
#	if current_page == 0:
#		last_btn.disabled = true
#	if current_page == total_pages - 1:
#		next_btn.disabled = true

	return


func _on_Next_pressed():
	load_next()


func _on_Last_pressed():
	load_last()


func _on_DescButton_pressed():
	desc_panel.hide()
