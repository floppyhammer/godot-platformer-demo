extends Panel

onready var text_label = $CenterC/Panel/ScrollC/RichTextLabel


func _ready():
	reload()


func reload():
	text_label.bbcode_text = tr("ABOUT_CONTENT")


func _on_CreditsPage_visibility_changed():
	if visible:
		reload()


func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)


func _on_Close_pressed():
	hide()
