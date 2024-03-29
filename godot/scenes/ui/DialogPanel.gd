extends Control

var dialog_folder = "res://dbs/dialogs" # Folder where the JSON files will be stored
var dialog
var progress

var current_step
var next_step = 'first'
var DEFAULT_TYPING_SPEED = 50
var typing_speed = DEFAULT_TYPING_SPEED
var typing_ended = false
export (bool) var debug = false


onready var dialog_c = $VBoxC/MarginC
onready var choices = $VBoxC/MarginC/VBoxC/ChoicesVBoxC
onready var text_label = $VBoxC/MarginC/VBoxC/HBoxC/BgPanel/TextLabel
onready var name_label = $VBoxC/MarginC/VBoxC/HBoxC/PanelC/VBoxC/NameLabel
onready var next_btn = $VBoxC/MarginC/VBoxC/HBoxC/BgPanel/TextLabel/Next
onready var tween = $Tween
onready var top_banner = $VBoxC/Top
onready var bottom_banner = $VBoxC/Bottom

signal typing_ended


func _ready():
	# Debug
	if debug:
		activate("test_dialog")
	
	next_btn.hide()


func _input(event):
	# 下一步
	if Input.is_action_just_pressed("B") and typing_ended:
		# 当前步为非问题时才能到下一步
		if current_step["type"] != "question":
			next()
	
	if Input.is_action_pressed("B"):
		typing_speed = DEFAULT_TYPING_SPEED * 5
	else:
		typing_speed = DEFAULT_TYPING_SPEED


func _process(delta):
	if current_step == null: return
	if dialog == null: return

	# Print the step label
	if text_label.percent_visible < 1.0 and text_label.text != "":
		text_label.percent_visible += delta * typing_speed / len(text_label.text)
		text_label.percent_visible = clamp(text_label.percent_visible, 0.0, 1.0)
	
	if not typing_ended and text_label.percent_visible == 1.0:
		typing_ended = true
		emit_signal('typing_ended')
		
		if current_step["type"] == "question" and choices.visible == false:
			# Make the first choice selected, so we can navigate through
			# the choices by keyboard.
			choices.get_child(0).grab_focus()
			
			choices.show()
			next_btn.hide()


func activate(dialog_name):
	Logger.debug("Activated dialog", "Dialog")
	
#	get_tree().paused = true
	Global.player_input_enabled = false
	
	# Hide choices
	choices.hide()
	
	dialog_c.modulate = Color.transparent
	
	# Show the dialog panel.
	show()
	
	tween.remove_all()
	tween.interpolate_property(top_banner, "rect_min_size", Vector2.ZERO, Vector2(0, 64), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(bottom_banner, "rect_min_size", Vector2.ZERO, Vector2(0, 64), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	
	dialog_c.modulate = Color.white
	
	print('Activated dialog: ' + dialog_name)
	
	dialog = JsonParser.read_data(dialog_folder + "/" + dialog_name + ".json")
	
	# This file should be in the user dir
	#if Global.save_data['progress'].has(dialog_name):
	#	progress = Global.save_data['progress'][dialog_name]
	
	first()


# Entry of a whole dialog
func first():
	# If the dialogues has branches depending on if it's the first interaction
	if dialog.has('repeat') and progress:
		# Checks if it's the first interaction
		if progress["first_meet"] != 1:
			# It's not, use the "repeat" step
			update_dialog(dialog['repeat'])
		else:
			# It is, use the "first" step
			progress["first_meet"] = 0
			update_dialog(dialog["first"])
	else:
		update_dialog(dialog['first'])


# Move forwards to the next dialog step
func update_dialog(step):
	current_step = step
	
#	if current_step.has('emotion'):
#		portrait.frame = current_step['emotion']
	
	name_label.text = current_step['char']
#	if current_step['char'] != '':
#		name_label.show()
#	else:
#		name_label.hide()

	# Check what kind of interaction the current step is 
	match step["type"]:
		# If the step is simple text
		"text":
			text_label.percent_visible = 0.0
			text_label.text = step["content"]
			
			# Set the next step
			next_step = step["next"] if step.has("next") else ""
			
		# If the step is a complex dialogue tree
		'divert':
			# All conditions have to be true to move to the true branch
			match step['condition']:
				'found_battery':
					if progress["found_battery"] == step['found_battery']:
						next_step = step['true']
					else:
						next_step = step['false']
			next()
		
		# If the step is a question
		'question':
			question(step['text'], step['options'], step['next'])
			
		# If the step is an action
		'action':
			next_step = step['next'] if step.has('next') else ''
			match step['value'][0]:
				'variable':
					pass
					#update_variable(step['value'][1], step['value'][2])
			if step.has('text'):
				text_label.percent_visible = 0.0
				text_label.text = step['text']
			else:
				next()


func next():
	next_btn.hide()
	
	# If not in the middle of a dialog 
	if not dialog: return
	
	# If the dialog is finished (no next step)
	if next_step == "":
		dialog = null
		
		dialog_c.modulate = Color.transparent
		
		tween.remove_all()
		tween.interpolate_property(top_banner, "rect_min_size", Vector2(0, 64), Vector2.ZERO, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(bottom_banner, "rect_min_size", Vector2(0, 64), Vector2.ZERO, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween, "tween_all_completed")
		
		hide()
		text_label.text = ""
		
#		get_tree().paused = false
		Global.player_input_enabled = true
		
		return
	
	# Reset typing status
	typing_ended = false
		
	# Move on to the next step
	update_dialog(dialog[next_step])


# Deal with question steps
func question(text, options, next):
	# Clear the label
	text_label.percent_visible = 0.0
	text_label.text = text
	
	choices.hide()
	
	# Reset all choices.
	for child in choices.get_children():
		child.hide()
	
	# Show valid choices.
	for i in range(len(options)):
		var choice = choices.get_child(i)
		
		choice.text = options[i]
		
		choice.show()


func _choice_pressed(id):
	choices.hide()
	
	if current_step["type"] == "question":
		next_step = current_step["next"][id]
		
		# Execute target function
		if current_step.has("funcs"):
			if Global.has_method(current_step["funcs"][id]):
				Global.call(current_step["funcs"][id])
	else:
		next_step = ''
	
	next()


# Hotload aduio
#func _play_audio(audio_name):
#	audio_player.set_stream(ResourceLoader.load(dialog_folder + '/' + audio_name + '.ogg'))
#	audio_player.get_stream().loop = false
#	audio_player.play()


func _on_Dialog_typing_ended():
	next_btn.show()


func _on_Next_pressed():
	next()


func _on_Choice1_pressed():
	_choice_pressed(0)


func _on_Choice2_pressed():
	_choice_pressed(1)


func _on_Choice3_pressed():
	_choice_pressed(2)
