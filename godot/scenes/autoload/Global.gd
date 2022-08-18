extends Node

# For passing parameters to the level scene when changing scene
var current_level = "1"
var items_to_bring = ["", "", ""]

# Main node
var main

# Databases
var level_db : Dictionary
var item_db : Dictionary
var tips : Dictionary

# Save data
var save_data = {
	"locale": "en",
	"coin": 0,
	"owned_items": {},
	"level_progress": {},
}

# Runtime nodes.
var hud
var player
var current_camera

signal progress_downloaded
signal locale_changed


func _ready():
	# Register loggers
	Logger.add_module("AdMob")
	Logger.add_module("Global", Logger.INFO)
	
	# Load dbs
	level_db = JsonParser.read_data("res://dbs/levels.json")
	Logger.verbose("Level db: " + str(level_db), "Global")
	item_db = JsonParser.read_data("res://dbs/items.json")
	Logger.verbose("Item db: " + str(item_db), "Global")
	
	# Load save data from file.
	var result = read_save_data()
	if result:
		Logger.info("Loaded local save file.", "Global")
		save_data = result
	else:
		Logger.info("Loading local save file failed, created a new one.", "Global")
		# Create new save data.
		save_data = _new_save_data()
	
	# Set locale
	change_locale(save_data["locale"])
	
	#NakamaConnection.connect("user_data_retrived", self, "_when_user_data_retrieved")


func _new_save_data() -> Dictionary:
	var new_save_data = save_data
	
	# Create new level progress
	for key in level_db:
		new_save_data["level_progress"][key] = {"stars": 0}
	
	# Create new item progress
	for key in item_db:
		new_save_data["owned_items"][key] = {"amount": 1}
		
	return new_save_data


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


func update_coin_count(change):
	# New coin number.
	save_data["coin"] += change


func get_coin_count():
	return save_data["coin"]


func update_level_progress(which_level, star_count):
	save_data["level_progress"][which_level] = {"stars": star_count}


func upload_save_data():
	pass
#	NakamaConnection.update_data("user_data", "basic", user_data)


func change_locale(code):
	# Set language.
	TranslationServer.set_locale(code)
	save_data["locale"] = TranslationServer.get_locale()
	emit_signal("locale_changed")


func write_save_data():
	JsonParser.write_data("user://save.json", save_data)


func read_save_data():
	return JsonParser.read_data("user://save.json")


func get_level_progress():
	return save_data["level_progress"]
