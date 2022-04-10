extends Control

onready var start_btn = $Start
onready var tip_label = $Tip

signal start_pressed


func _ready():
	#title_rect.texture = load("res://assets/ui/title_%s.png" % TranslationServer.get_locale())
	
	tip_label.text = tr("TAP_ANYWHERE")


func _on_Start_pressed():
	start_btn.disabled = true
	
	$Start.hide()
	
	emit_signal("start_pressed")
