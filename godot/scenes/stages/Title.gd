extends Control

onready var play_btn = $VBoxContainer/Play

signal start_pressed


func _ready():
	# Image title.
	#title_rect.texture = load("res://assets/ui/title_%s.png" % TranslationServer.get_locale())
	
	pass


func _on_Play_pressed():
	play_btn.disabled = true
	
	emit_signal("start_pressed")
