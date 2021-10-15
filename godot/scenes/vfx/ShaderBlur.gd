extends ColorRect

export (float, 0, 5, 0.1) var blur_amount = 2.0
export (bool) var debug = false

var bg_color : Color

onready var tween = $Tween


func _ready():
	bg_color = color
	
	# Need to set a value the first time, otherwise the shader param would be null
	$Shader.material.set_shader_param("blur_amount", blur_amount)


func _input(event):
	if not debug: return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				change_blur_amount(2, 1)
			else:
				change_blur_amount(0, 1)


func change_blur_amount(value, duration, delay=0):
	tween.remove_all()
	tween.interpolate_property($Shader.material, "shader_param/blur_amount", $Shader.material.get_shader_param("blur_amount"),
		value, duration, Tween.TRANS_SINE, Tween.EASE_OUT, delay)
	if value > 0:
		tween.interpolate_property(self, "color", color,
			bg_color, duration, Tween.TRANS_SINE, Tween.EASE_OUT, delay)
	else:
		tween.interpolate_property(self, "color", color,
			Color.transparent, duration, Tween.TRANS_SINE, Tween.EASE_OUT, delay)
	tween.start()
