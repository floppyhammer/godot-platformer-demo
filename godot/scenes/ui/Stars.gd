extends TextureRect


func _ready():
	update_looking(1)


func update_looking(star_num):
	star_num = clamp(star_num, 1, 3)
	$TextureRect.texture.current_frame = star_num - 1
