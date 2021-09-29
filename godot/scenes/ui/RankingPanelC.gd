extends Panel

onready var list = $Panel/VBoxC/Coin
var is_appearing = false
onready var tween = $Tween


func _ready():
	hide()
	
	list.clear()
	
	_update_language()
	Global.connect("locale_changed", self, "_when_locale_changed")


func _when_locale_changed():
	_update_language()


func _update_language():
	$Panel/VBoxC/PageTitle.text = tr("RANKING")


func show_elegantly():
	is_appearing = true
	show()
	tween.interpolate_property(self, "self_modulate", self_modulate, Color.white, 0.2)
	tween.interpolate_property($Panel, "rect_position", $Panel.rect_position, Vector2($Panel.rect_position.x, rect_size.y - 960), 0.2)
	tween.interpolate_property($Panel, "rect_size", $Panel.rect_size, Vector2($Panel.rect_size.x, 960), 0.2)
	tween.start()


func hide_elegantly():
	is_appearing = false
	tween.interpolate_property(self, "self_modulate", self_modulate, Color.transparent, 0.2)
	tween.interpolate_property($Panel, "rect_position", $Panel.rect_position, Vector2($Panel.rect_position.x, rect_size.y), 0.2)
	tween.interpolate_property($Panel, "rect_size", $Panel.rect_size, Vector2($Panel.rect_size.x, 0), 0.2)
	tween.start()


func _on_RankingPanelC_visibility_changed():
	# Do nothing on hiding
	if not visible: return
	
	# Fetch leaderboard
	var ranking_list = yield(NakamaConnection.fetch_leaderboard(), "completed")
	
	# Fetch user accounts
	var user_ids = []
	for entry in ranking_list:
		user_ids.append(entry.owner_id)
	var users = yield(NakamaConnection.fetch_users_by_ids(user_ids), "completed")
	
	# Clear list
	list.clear()
	
	# Add items to the list
	for i in range(ranking_list.size()):
		var icon = null
		if ranking_list[i].rank == "1":
			icon = load("res://assets/ui/trophy_gold.png")
		elif ranking_list[i].rank == "2":
			icon = load("res://assets/ui/trophy_silver.png")
		elif ranking_list[i].rank == "3":
			icon = load("res://assets/ui/trophy_bronze.png")
		
		# TODO: users[i].display_name. Leaderboard does not update when users are deleted
		list.add_item("%s. %s %s" % [ranking_list[i].rank, ranking_list[i].username, ranking_list[i].score], icon)


func _on_RankingPanelC_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			hide_elegantly()


func _on_Tween_tween_all_completed():
	if is_appearing:
		pass
	else:
		hide()
