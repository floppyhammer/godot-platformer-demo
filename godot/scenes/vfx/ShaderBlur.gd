extends ColorRect

export (float, 0, 5, 0.1) var blur_amount = 2.0


func _ready():
	# Need to set a value the first time, otherwise the shader param would be null
	$Shader.material.set_shader_param("blur_amount", blur_amount)


func change_blur_amount(value, duration, delay=0):
	$Tween.interpolate_property($Shader.material, "shader_param/blur_amount", $Shader.material.get_shader_param("blur_amount"),
		value, duration, Tween.TRANS_SINE, Tween.EASE_OUT, delay)
	$Tween.start()
