extends MarginContainer


var btn_group = ButtonGroup.new()

onready var grid = $ScrollC/GridC
onready var desc_panel = $InfoPanel
onready var description_label = $InfoPanel/Info

var item_scene = preload("res://scenes/ui/menu/InventoryItem.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	desc_panel.hide()
	
	_reload()


func _when_button_down():
	for i in range(grid.get_child_count()):
		if grid.get_child(i) == btn_group.get_pressed_button():
			var item_key = grid.get_child(i).get_node("Metadata").text
			if Global.item_db.has(item_key):
				description_label.bbcode_text = Global.item_db[item_key]["description_%s" % TranslationServer.get_locale()]
				desc_panel.show()


func _reload():
	var db = Global.item_db
	var owned_items = Global.save_data["owned_items"]
	
	for child in grid.get_children():
		child.free()
	
	for key in owned_items:
		if owned_items[key]["amount"] > 0:
			var button = item_scene.instance()
			button.texture_normal = load(db[key]["texture"])
			button.get_node("Metadata").text = key
			button.get_node("Amount").text = str(owned_items[key]["amount"])
			button.group = btn_group
			grid.add_child(button)


func _on_DescButton_pressed():
	desc_panel.hide()
