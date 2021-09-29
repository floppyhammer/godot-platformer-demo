extends TextureButton

# String key of the level.
export (String) var level_id : String = "1"

onready var stars_parent = $HBoxContainer

func update_looking(star_number, playable : bool):
	texture_disabled = load("res://assets/ui/button_level_locked.png")
	
	# Set stars.
	for child in stars_parent.get_children():
		child.hide()
	for i in range(star_number):
		stars_parent.get_child(i).show()
	
	# Playable level.
	if playable:
		disabled = false
		$Label.text = str(level_id)
		
		texture_normal = load("res://assets/ui/button_level.png")
	else: # Locked level.
		disabled = true
		$Label.text = ""
	
	# Make the press animation centered.
	rect_pivot_offset = rect_size / 2


func _on_LevelButton_pressed():
	$AnimPlayer.play("pressed")
