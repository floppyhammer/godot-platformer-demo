extends PanelContainer


var score_change = 0
var is_assessing = false
var score = 0
var score2coin_ratio = 1
var coin_sound_index = 1

onready var fireworks_left = $Fireworks/CenterLeft/Fireworks
onready var fireworks_right = $Fireworks/CenterRight/Fireworks

signal level_restarted
signal level_moved_on
signal level_quitted


func _ready():
	Logger.add_module("ResultPanel")


func show_with_transition():
	# Have to show itself first for the transition effect to be visible.
	show()
	
	# Play the transition effect.
	$AnimPlayer.play("appear")


func hide_with_transition():
	# Play the transition effect.
	$AnimPlayer.play("disappear")


func show_when_level_is_clear(level_name, star_count, coin_count):
	#$CenterC/PanelC/VBoxC/Title.text = tr("CLEAR_TITLE")
	
	# Wallet updater payload
#	var payload = {"coin": coin_got}
#	
#	var rpc_id = "update_wallet"
#	var wallet_info : NakamaAPI.ApiRpc = yield(NakamaConnection.client.rpc_async(NakamaConnection.session, rpc_id, JSON.print(payload)), "completed")
#	if wallet_info.is_exception():
#		print("[Network] An error occured: %s" % wallet_info)
	
	# Update offline coin.
	#Global.update_coin(coin_count)
	
	# Update offline and online progress.
	Global.update_level_progress(level_name, star_count)
	
	# Update online leaderboard.
	#NakamaConnection.update_leaderboard("金币", Global.coin_count)
	
	show_with_transition()
	
	fireworks_left.hide()
	fireworks_right.hide()
	
	yield($AnimPlayer, "animation_finished")
	
	fireworks_left.show()
	fireworks_left.restart()
	fireworks_right.show()
	fireworks_right.restart()
	
	Global.write_save_data()
	
	$ReturnTimer.start()
	yield($ReturnTimer, "timeout")
	emit_signal("level_quitted")
	
	var main_node = get_node_or_null("/root/Main")
	if main_node:
		get_node("/root/Main").loading_panel.load_scene("res://scenes/stages/Home.tscn")
	else:
		Logger.error('get_node("/root/Main") returned null!', "ResultPanel")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "disappear":
		# Hide itself after the transition effect finished.
		hide()
	elif anim_name == "appear":
		pass


func _on_ResultPanel_visibility_changed():
	# Pause the game if the result panel is shown.
	get_tree().paused = visible
