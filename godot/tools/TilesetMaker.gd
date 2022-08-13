extends Sprite

export var tile_size = Vector2(16, 16)
export var tileset_name = 'default'


func _ready():
	var cols = texture.get_width() / tile_size.x
	var rows = texture.get_height() / tile_size.y
	
	print('Frames: ', rows, '*', cols)
	
	var my_tileset = TileSet.new()
	
	# Scan by row
	for r in range(rows):
		for c in range(cols):
			
			var region = Rect2(c * tile_size.x, r * tile_size.y, tile_size.x, tile_size.y)
			var id = cols * r + c
			print(id)
			
			my_tileset.create_tile(id)
			my_tileset.tile_set_texture(id, texture)
			my_tileset.tile_set_region(id, region)
			
			var shape = RectangleShape2D.new()
			shape.extents = tile_size / 2
			my_tileset.tile_set_shape(id, id, shape)
			my_tileset.tile_set_shape_offset(id, id, tile_size / 2)

	ResourceSaver.save("res://scenes/maps/tilesets/" + tileset_name + ".tres", my_tileset)
	print("Tileset created successfully!")
