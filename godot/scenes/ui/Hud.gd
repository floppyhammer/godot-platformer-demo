extends Control


onready var menu_btn = $Margin/Control/MenuButton
onready var menu_panel = $MenuPanel
onready var tween = $Tween
onready var dialog = $DialogPanel
onready var notification_spawner = $NotificationSpawner
onready var shop_panel = $ShopPanel
onready var joystick = $Joystick
onready var level_label = $Margin/Control/LevelTag/Label


func _ready():
	Logger.add_module("HUD")
	
	Global.hud = self
	
	$BlurShader.show()
	$BlurShader.change_blur_amount(0, 0)
	
	Global.connect("locale_changed", self, "_when_locale_changed")
	
	level_label.text = Global.current_level_name


func add_notification(p_text : String):
	notification_spawner.add_notification(p_text)


func _show_menu():
	$BlurShader.change_blur_amount(2, 0.5)
	
	joystick.hide()
	$Margin.hide()
	
	# Show menu panel with transition.
	menu_panel.show()
	tween.remove_all()
	tween.interpolate_property(menu_panel, "modulate", Color.transparent, Color.white, 0.2)
	tween.start()
	
	get_tree().paused = true


func _hide_menu():
	$BlurShader.change_blur_amount(0, 0.5)
	
	joystick.show()
	$Margin.show()
	menu_panel.hide()
	
	# Hide menu panel with transition.
	tween.remove_all()
	tween.interpolate_property(menu_panel, "modulate", Color.white, Color.transparent, 0.2)
	tween.start()
	
	get_tree().paused = false


func show_shop_panel():
	$BlurShader.change_blur_amount(2, 0.5)
	
	joystick.hide()
	
	menu_btn.hide()
	menu_panel.hide()
	shop_panel.show_elegantly()
	
	get_tree().paused = true


func _on_ShopPanel_when_hiden():
	$BlurShader.change_blur_amount(0, 0.5)
	
	joystick.show()
	
	menu_btn.show()
	
	get_tree().paused = false


func _on_MenuButton_pressed():
	_show_menu()


func _on_MenuPanel_when_closed():
	_hide_menu()
