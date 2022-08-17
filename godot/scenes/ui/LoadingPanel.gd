extends Control

var thread = Thread.new()
var is_appearing = false

onready var transition_panel = $TransitionPanel

signal loading_finished


func _ready():
	hide()


func load_scene(scene_path):
	show()
	
	transition_panel.appear()
	yield(transition_panel, "appeared")
	
	# Change the scene only after the transition panel is fully opaque.
	var running_node = get_node_or_null("/root/Main/Running")
	if running_node:
		for child in running_node.get_children():
			child.queue_free()
	
	# Start background loading.
	if thread.is_active(): return
	thread.start(self, "_load_scene_in_thread", scene_path)
	yield(self, "loading_finished")
	
	transition_panel.disappear()
	yield(transition_panel, "disappeared")
	hide()


func _when_loading_completed():
	var level = thread.wait_to_finish()
	
	var running_node = get_node_or_null("/root/Main/Running")
	if running_node:
		running_node.add_child(level)
	
	emit_signal("loading_finished")


# Threads always take one userdata argument.
func _load_scene_in_thread(scene_path):
	# Do heavy work
	var level_scene = load(scene_path)
	var new_level = level_scene.instance()
	
	# Call method on the main thread
	call_deferred("_when_loading_completed")
	
	return new_level
