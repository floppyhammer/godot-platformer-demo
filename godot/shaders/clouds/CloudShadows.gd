tool
extends Sprite

# Connect "item_rect_changed" signal in Editor instead of in script


func _ready():
	update_shader_aspect_ratio()
	
	get_node("/root").transparent_bg = true


func update_shader_aspect_ratio():
	material.set_shader_param("aspect_ratio", scale.y / scale.x)


func _on_CloudShadows_item_rect_changed():
	update_shader_aspect_ratio()
