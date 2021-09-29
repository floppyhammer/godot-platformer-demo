extends Control

var thread = Thread.new()
var is_appearing = false

onready var transition = $Transition

signal loading_finished


func _ready():
	hide()


func load_scene(scene_path):
	show()
	
	transition.appear()
	yield(transition, "appeared")
	
	# Start background loading.
	if thread.is_active(): return
	thread.start(self, "_load_scene_in_thread", scene_path)
	
	yield(self, "loading_finished")
	transition.disappear()


func _when_loading_completed():
	var level = thread.wait_to_finish()
	
	get_node("/root/Main/Running").add_child(level)
	
	emit_signal("loading_finished")


# Threads always take one userdata argument
func _load_scene_in_thread(scene_path):
	# Do heavy work
	var level_scene = load(scene_path)
	var new_level = level_scene.instance()
	
	# Call method on the main thread
	call_deferred("_when_loading_completed")
	
	return new_level


func _on_Transition_appeared():
	for child in get_node("/root/Main/Running").get_children():
		child.queue_free()


func _on_Transition_disappeared():
	hide()
