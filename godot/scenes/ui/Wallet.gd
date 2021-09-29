extends Control

onready var tree = $CenterC/Popup/VBoxC/Tree


func _ready():
	hide()


func _reload():
	NakamaConnection.retrieve_account()
	
	var wallet_dict = JSON.parse(NakamaConnection.account.wallet).result
	
	tree.clear()
	var root = tree.create_item()
	
	for k in wallet_dict:
		var tree_item = tree.create_item(root)
		tree_item.set_text(0, "%s (%d)" % [k, wallet_dict[k]])


func _on_Wallet_gui_input(event):
	pass


func _on_CenterC_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			hide()


func _on_Wallet_visibility_changed():
	if visible:
		_reload()
