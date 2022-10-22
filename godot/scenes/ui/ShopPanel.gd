extends Control

"""
Health points are the currency!
"""


onready var list = $Panel/Margin/VBox/ItemList
onready var description_label = $Panel/Margin/VBox/Description
onready var buy_btn = $Panel/Margin/VBox/VBox/Buy

signal when_hiden


func _input(event):
	if Input.is_action_just_pressed("jump"):
		_on_ShopPage_pressed()


func _reload():
	# Reset
	description_label.bbcode_text = ""
	
	var db = Global.item_db
	var owned_items = Global.save_data["owned_items"]
	
	list.unselect_all()
	list.clear()
	
	for key in db:
		var amount = owned_items[key]["amount"]
		var item_name = db[key]["name_%s" % TranslationServer.get_locale()] + " (%d)" % amount
		list.add_item(item_name, load(db[key]["texture"]))
		list.set_item_metadata(list.get_item_count() - 1, key)


func _on_ItemList_item_selected(index):
	var item_key = list.get_item_metadata(index)
	if item_key == null: return
	
	var text = "[right]%s: [color=#ffb63a]%d[/color][/right]\n" % [tr("PRICE"), Global.item_db[item_key]["price"]]
	text += Global.item_db[item_key]["description_%s" % TranslationServer.get_locale()]
	description_label.bbcode_text = text


func _on_Buy_pressed():
	if list.get_selected_items().size() == 0: return
	
	var item_key = list.get_item_metadata(list.get_selected_items()[0])
	var owned_items = Global.save_data["owned_items"]
	var price = Global.item_db[item_key]["price"]
	
	if Global.get_coin_count() < price:
		description_label.show()
		Global.hud.add_notification("You can't afford this!")
	else:
		Global.update_coin_count(-price)
		owned_items[item_key]["amount"] += 1


func show_elegantly():
	_reload()
	
	show()
	$Tween.interpolate_property(self, "modulate", modulate, Color.white, 0.2)
	$Tween.start()
	yield($Tween, "tween_all_completed")


func hide_elegantly():
	$Tween.interpolate_property(self, "modulate", modulate, Color.transparent, 0.2)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	hide()


func _on_ShopPage_pressed():
	hide_elegantly()
	emit_signal("when_hiden")
