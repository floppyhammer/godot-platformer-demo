extends Node

# For passing parameters to the level scene when changing scene
var current_level = "1"
var items_to_bring = ["", "", ""]

# Databases
var level_db : Dictionary
var tips : Dictionary
var block_db = {}
var item_db = {}
var gourmand_db = {}

# Main node
var main

# Save data
var general = {
	"coin": 0,
	"locale": "en",
	"selected_gourmand": "PUPU",
	"level_progress": {},
	"gourmand_progress": {},
	"block_progress": {},
	"item_progress": {}
}
var level_progress = {}
var gourmand_progress = {}
var block_progress = {}
var item_progress = {}

# Runtime nodes.
var hud

signal progress_downloaded
signal locale_changed


func _ready():
	# Register loggers
	Logger.add_module("Level")
	Logger.add_module("AdMob")
	
	# Load dbs
	level_db = JsonParser.read_data("res://dbs/levels.json")
	block_db = JsonParser.read_data("res://dbs/blocks.json")
	item_db = JsonParser.read_data("res://dbs/items.json")
	gourmand_db = JsonParser.read_data("res://dbs/gourmands.json")
	
	# Load settings locally
	var result = load_general_save_data()
	if result:
		# Load progress
		general = result
		level_progress = general["level_progress"]
		gourmand_progress = general["gourmand_progress"]
		block_progress = general["block_progress"]
		item_progress = general["item_progress"]
	else:
		# Create new progress
		_set_init_progress()
	
	# Set locale
	change_locale(general["locale"])
	
	#NakamaConnection.connect("user_data_retrived", self, "_when_user_data_retrieved")


func _set_init_progress():
	# Create new level progress
	for key in level_db:
		level_progress[key] = {"stars": 0}

	# Create new block progress
	for key in block_db:
		block_progress[key] = {"discovered": false}
	
	# Create new item progress
	for key in item_db:
		item_progress[key] = {"amount": 1}
	
	# Create new gourmand progress
	for key in gourmand_db:
		gourmand_progress[key] = {"possessed": false}
	gourmand_progress["PUPU"]["possessed"] = true


#func _when_user_data_retrieved():
#	# Retrieve level progress (with backwards compatibility)
#	if NakamaConnection.user_data.has("level_progress"):
#		var cloud_progress = NakamaConnection.user_data["level_progress"]
#
#		# Copy valid data and get rid of deprecated data
#		for key in cloud_progress:
#			# key is level name
#			if cloud_progress.has(key):
#				level_progress[key] = cloud_progress[key]
#
#	# Retrieve handbook progress (with backwards compatibility)
#	if NakamaConnection.user_data.has("block_progress"):
#		var cloud_progress = NakamaConnection.user_data["block_progress"]
#
#		# Copy valid data and get rid of deprecated data
#		for key in cloud_progress:
#			if block_progress.has(key):
#				block_progress[key] = cloud_progress[key]
#
#	emit_signal("progress_downloaded")


func update_coin(change):
	# New coin number
	general["coin"] += change


func get_coin():
	return general["coin"]


func get_selected_gourmand():
	return general["selected_gourmand"]


func update_progress(which_level, stars):
	# If save data does not have such a level included
	level_progress[which_level] = {"stars": stars}


func upload_progress():
	save_general_save_data()
#	var user_data = {
#		"level_progress": level_progress,
#		"block_progress": block_progress,
#	}
#
#	NakamaConnection.update_data("user_data", "basic", user_data)


func change_locale(code):
	# Set language
	TranslationServer.set_locale(code)
	emit_signal("locale_changed")


func save_general_save_data():
	general["level_progress"] = level_progress
	general["gourmand_progress"] = gourmand_progress
	general["block_progress"] = block_progress
	general["item_progress"] = item_progress
	general["locale"] = TranslationServer.get_locale()
	JsonParser.write_data("user://general.json", general)


func load_general_save_data():
	var result = JsonParser.read_data("user://general.json")
	
	return result
