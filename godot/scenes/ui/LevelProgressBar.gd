extends TextureRect


func update_progress(value):
	$Path2D/PathFollow2D.unit_offset = clamp(value, 0, 1)
