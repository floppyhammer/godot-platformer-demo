extends Panel

onready var page_title = $CenterC/Panel/VBoxC/PageTitle
onready var text_label = $CenterC/Panel/VBoxC/ScrollC/RichTextLabel


func _ready():
	prepare()


func prepare():
	page_title.text = tr("ABOUT")
	text_label.bbcode_text = tr("ABOUT_CONTENT")


func _on_CreditsPage_visibility_changed():
	if visible:
		prepare()


func _on_CreditsPage_gui_input(event):
	if event is InputEventScreenTouch:
		if not event.pressed:
			hide()


func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)
