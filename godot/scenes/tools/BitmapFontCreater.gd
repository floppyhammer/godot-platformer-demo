extends Sprite

var save_path = "res://assets/fonts/bitmap_font.tres"
var size = Vector2(48, 64)

var dict = {
	"0": {"rect": Rect2(0, 0, 1, 1), "unicode_id": 48},
	"1": {"rect": Rect2(1, 0, 1, 1), "unicode_id": 49},
	"2": {"rect": Rect2(2, 0, 1, 1), "unicode_id": 50},
	"3": {"rect": Rect2(3, 0, 1, 1), "unicode_id": 51},
	"4": {"rect": Rect2(4, 0, 1, 1), "unicode_id": 52},
	"5": {"rect": Rect2(5, 0, 1, 1), "unicode_id": 53},
	"6": {"rect": Rect2(6, 0, 1, 1), "unicode_id": 54},
	"7": {"rect": Rect2(7, 0, 1, 1), "unicode_id": 55},
	"8": {"rect": Rect2(8, 0, 1, 1), "unicode_id": 56},
	"9": {"rect": Rect2(9, 0, 1, 1), "unicode_id": 57},
}


func _ready():
	var font = BitmapFont.new()
	
	font.add_texture(texture)
	
	for key in dict:
		font.add_char(dict[key]["unicode_id"],
			0, Rect2(dict[key]["rect"].position * size, dict[key]["rect"].size * size))
	
	font.height = size.y
	
	ResourceSaver.save(save_path, font)
	
	if File.new().file_exists(save_path):
		print("Bitmap font created!")
