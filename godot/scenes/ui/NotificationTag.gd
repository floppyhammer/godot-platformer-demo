extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color.white
	$Tween.interpolate_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), Color.white, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "modulate", Color.white, Color(1.0, 1.0, 1.0, 0.0), 1, Tween.TRANS_SINE, Tween.EASE_OUT, 3)
	$Tween.start()


func _on_Tween_tween_all_completed():
	queue_free()
