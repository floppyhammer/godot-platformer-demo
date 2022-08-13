extends TextureButton


# String key of the level.
export (String) var level_id : String = "1"

onready var stars = $HBox


func update_looking(star_number, playable : bool):
	# Set stars.
	for child in stars.get_children():
		child.hide()
	for i in range(star_number):
		stars.get_child(i).show()
	
	# Playable level.
	if playable:
		disabled = false
		$Label.text = str(level_id)
	else: # Locked level.
		disabled = true
		$Label.text = ""
	
	# Make the press animation centered.
	rect_pivot_offset = rect_size / 2
