extends Control

onready var menu_btn = $VBoxC/Panel/HBoxC/HBoxC/Menu
onready var exit_btn = $VBoxC/Panel/HBoxC/HBoxC/Exit
onready var menu_panel = $VBoxC/MenuPanel


func _ready():
	Global.hud = self
	_hide_menu()
	$ResultPanel.hide()
	
	var level_name = get_parent().get_parent().get("level_name")
	if level_name is String:
		$MapLabel.text = level_name


func show_result_panel():
	$ResultPanel.show_when_level_is_clear("Level 1", 10, 10)


func _show_menu():
	$Joystick.hide()
	menu_panel.show()
	exit_btn.show()
	
	get_tree().paused = true


func _hide_menu():
	$Joystick.show()
	menu_panel.hide()
	exit_btn.hide()
	
	get_tree().paused = false


func _on_Menu_toggled(button_pressed):
	if button_pressed:
		_show_menu()
		menu_btn.text = "Resume"
	else:
		_hide_menu()
		menu_btn.text = "Menu"


func _on_Exit_pressed():
	get_node("/root/Main").loading_panel.load_scene("res://scenes/stages/Home.tscn")
