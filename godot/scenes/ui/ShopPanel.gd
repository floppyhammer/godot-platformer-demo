extends Control


onready var list = $Panel/Margin/VBox/ItemList
onready var description_label = $Panel/Margin/VBox/Description
onready var buy_btn = $Panel/Margin/VBox/VBox/Buy
onready var coin_label = $Panel/Margin/VBox/VBox/CoinLabel


func _reload():
	# Translation
	buy_btn.text = tr("BUY")
	
	# Reset
	description_label.bbcode_text = ""
	
	var db = Global.item_db
	var progress = Global.item_progress
	
	coin_label.text = str(Global.get_coin())
	
	list.unselect_all()
	list.clear()
	
	for key in db:
		var amount = progress[key]["amount"]
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
	var progress = Global.item_progress
	var price = Global.item_db[item_key]["price"]
	
	if Global.get_coin() < price:
		description_label.bbcode_text = "You cannot afford that!"
	else:
		Global.update_coin(-price)
		progress[item_key]["amount"] += 1
	
	_reload()


func show_elegantly():
	_reload()
	
	show()
	$Tween.interpolate_property(self, "modulate", modulate, Color.white, 0.2)
	$Tween.start()
	yield($Tween, "tween_all_completed")


func hide_elegantly():
	Global.save_general_save_data()
	
	$Tween.interpolate_property(self, "modulate", modulate, Color.transparent, 0.2)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	hide()


func _on_ShopPage_pressed():
	hide_elegantly()
