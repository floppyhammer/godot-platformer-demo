extends Control

######## Level config ########
var level_name : String
var level_config : Dictionary
var target_score : int
var rewards = 0
var items : Array
export (String) var level_name_override = ""
######## Level config ########

var star_num = 3

onready var pause_btn = $PanelC/VBoxC/Bottom/HBoxC/Pause
onready var play_grid = $PanelC/VBoxC/Middle/SizeAdapter/PlayPanel/PlayGrid

onready var level_label = $PanelC/VBoxC/Top/HBoxC/Center/LevelLabel
onready var target_label = $PanelC/VBoxC/Top/HBoxC/HBoxCRight/ScoreProgress/TargetScore
onready var score_progress = $PanelC/VBoxC/Top/HBoxC/HBoxCRight/ScoreProgress

onready var target_box = null
onready var item_box = $PanelC/VBoxC/Bottom/HBoxC/Panel/ItemBox
onready var star_box = $PanelC/VBoxC/Top/HBoxC/HBoxCLeft/FallingTimerProgress

onready var result_panel = $ResultPanel
onready var tween = $Tween
onready var gourmand = $PanelC/VBoxC/Top/HBoxC/Center/Gourmand

onready var falling_timer_progess = $PanelC/VBoxC/Top/HBoxC/HBoxCLeft/FallingTimerProgress

var is_testing = false

# TODO: Make a distinction
# Items are brought into the level
# Map objects are in the level


func _ready():
	# BGM
	if has_node("/root/Main/BGMPlayer"):
		get_node("/root/Main/BGMPlayer").start_bgm("res://assets/music/happy_tune_by_syncopika.ogg")

	# Theme
	#$PanelC/VBoxC/RefRect/CenterC/PlayPanel.get("custom_styles/panel").texture = load("res://assets/ui/%s/panel_play_grid.png" % Global.theme)
	#$PanelC/VBoxC/Bottom/HBoxC/Panel.texture = load("res://assets/ui/%s/panel_items.png" % Global.theme)
	
	# Gourmand sprite
	$PanelC/VBoxC/Top/HBoxC/Center/Gourmand.texture = load(Global.gourmand_db[Global.get_selected_gourmand()]["texture"])
	
	result_panel.hide()
	
	if level_name_override:
		Global.current_level = level_name_override
	
	if Global.level_db.has(Global.current_level):
		prepare(Global.current_level, Global.level_db[Global.current_level], Global.items_to_bring)
	else:
		print("Entering level %s failed. No such a level!" % level_name)


func _process(delta):
	var first_half = clamp(play_grid.falling_timer_ratio - 0.5, 0, 0.5) * 2
	var second_half = 1 - clamp(0.5 - play_grid.falling_timer_ratio, 0, 0.5) * 2

	var color = Color(1 - first_half, second_half, 0)
	#print(first_half, "-", second_half)
	
	falling_timer_progess.tint_progress = color
	falling_timer_progess.value = lerp(falling_timer_progess.value, 100 * play_grid.falling_timer_ratio, delta * 10)


# Initialize the level
func prepare(level_name : String, level_config : Dictionary, items_brought_in : Array = []):
	# Set level up
	self.level_name = level_name
	self.level_config = level_config
	level_label.text = tr("LEVEL_NAME") % level_name
	target_score = level_config["score"]
	rewards = level_config["rewards"]["coin"]
	
	play_grid.reset_level(level_config["matrix"])
	
	# Add items
	for child in item_box.get_children():
		child.queue_free()
	for item in items_brought_in:
		if item == "":
			continue
		var item_scene = load(Global.item_db[item]["scene_path"])
		var item_node = item_scene.instance()
		item_box.add_child(item_node)
	
	# Update UI
	_update_ui()
	
	result_panel.hide()
	
	$TestLabel.text = ""


func _update_ui():
	# Update displayed level info
	target_label.text = "%d" % [target_score]
	
	$Tween.interpolate_property(score_progress, "value", score_progress.value, float(play_grid.score) / target_score * 100, 0.2)
	$Tween.start()


func _when_game_lost():
	result_panel.show_when_lost()


func _when_game_won():
	result_panel.show_when_won(level_name, target_score, star_num, rewards)


func _on_Menu_pressed():
	if is_testing:
		set_process_input(false)
		hide()
	
	result_panel.show_when_paused()


func _on_ResultPanel_level_moved_on():
	if Global.level_db[Global.current_level].has("next"):
		Global.current_level = Global.level_db[Global.current_level]["next"]

		prepare(Global.current_level, Global.level_db[Global.current_level])


func _on_ResultPanel_level_quitted():
	get_node("/root/Main/BGMPlayer").stop_bgm()
	get_node("/root/Main/LoadingPanel").load_scene("res://scenes/ui/Home.tscn")


func _on_ResultPanel_level_restarted():
	prepare(level_name, level_config)


func _on_Level_item_rect_changed():
	# Make play panel square
	var square_size = min(rect_size.x, $PanelC/VBoxC/Middle.rect_size.y)
	$PanelC/VBoxC/Middle/SizeAdapter.rect_min_size = Vector2.ONE * square_size


func _on_StartPanel_visibility_changed():
	if $StartPanel.visible:
		return


func _on_PlayGrid_block_created(new_block_id, new_block_center_pos):
	_update_ui()
	
	if new_block_id % 3 == 0:
		Logger.info("Consumed block %d" % new_block_id, "Level")
		var consumed_block = Sprite.new()
		
		consumed_block.texture = load(Global.block_db["block %d" % new_block_id]["texture"])
		consumed_block.scale = Vector2.ONE * play_grid.size / consumed_block.texture.get_size().x
		add_child(consumed_block)
		consumed_block.global_position = new_block_center_pos
		tween.interpolate_property(consumed_block, "global_position", new_block_center_pos, gourmand.global_position, 0.5)
		tween.start()
		yield(tween, "tween_completed")
		
		if play_grid.score >= target_score:
			_when_game_won()
			
			# Send vibration
			Input.vibrate_handheld(500)


func _on_Tween_tween_completed(object, key):
	# Delete consumed block
	if key == ":global_position":
		object.queue_free()


func _on_PlayGrid_reached_bottom():
	_when_game_lost()


func _on_PlayGrid_assessment_changed(assessment):
	match assessment:
		"A":
			pass
		"B":
			star_num = 2
		"C":
			star_num = 1
	
	# Update UI
	for child in star_box.get_children():
		child.hide()
	for i in range(star_num):
		star_box.get_child(i).show()


func _on_PlayGrid_just_operated():
	_update_ui()
