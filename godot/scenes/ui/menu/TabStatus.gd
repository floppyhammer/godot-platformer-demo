extends MarginContainer

var current_no = 0 # Currently shown item.
var total_no = 0 # Total items count.
var items = []

onready var select_btn = $VBoxC/HBoxC/VBoxC/Select
onready var portrait = $VBoxC/HBoxC/VBoxC/Portrait
onready var name_label = $VBoxC/HBoxC/VBoxC/NameLabel
onready var desc_label = $VBoxC/DescriptionLabel
onready var no_label = $VBoxC/HBoxC2/NoLabel
onready var last_btn = $VBoxC/HBoxC2/Last
onready var next_btn = $VBoxC/HBoxC2/Next


func _ready():
	reset()


func reset():
	current_no = 0
	_reload()


func load_last():
	current_no -= 1
	_reload()


func load_next():
	current_no += 1
	_reload()


func _reload():
	# Translation.
	select_btn.text = tr("SELECTED")
	
	total_no = 0
	items.clear()
	for key in Global.gourmand_db:
		items.append(key)
		if total_no == current_no:
			var xname = "???"
			var description = "???"
			
			# Shown item is the equipped one.
			if Global.gourmand_progress[key]["possessed"]:
				portrait.self_modulate = Color("ffffff")
				xname = Global.gourmand_db[key]["name_%s" % TranslationServer.get_locale()]
				description = Global.gourmand_db[key]["description_%s" % TranslationServer.get_locale()]
			else:
				portrait.self_modulate = Color("000000")
			
			# Update shown info.
			name_label.text = xname
			portrait.texture = load(Global.gourmand_db[key]["texture"])
			desc_label.bbcode_text = description
		
		total_no += 1
	
	current_no = clamp(current_no, 0, total_no - 1)
	
	# Update index label.
	no_label.text = str(current_no + 1)
	
	last_btn.disabled = false
	next_btn.disabled = false
	if current_no == 0:
		last_btn.disabled = true
	if current_no == total_no - 1:
		next_btn.disabled = true
	
	# Shown item is the equipped one.
	if items[current_no] == Global.general["selected_gourmand"]:
		select_btn.pressed = true
		select_btn.disabled = true
		select_btn.text = tr("SELECTED")
	else:
		if Global.gourmand_progress[items[current_no]]["possessed"]:
			select_btn.disabled = false
			select_btn.text = tr("SELECT")
		else:
			select_btn.disabled = true
			select_btn.text = tr("NOT_FOUND")
		select_btn.pressed = false
		
	return


func _on_Next_pressed():
	load_next()


func _on_Last_pressed():
	load_last()


func _on_Select_pressed():
	Global.general["selected_gourmand"] = items[current_no]
	select_btn.disabled = true
	select_btn.text = tr("SELECTED")
