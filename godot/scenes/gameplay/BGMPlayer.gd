extends AudioStreamPlayer

onready var tween = $Tween
signal volume_decreased_to_zero
signal volume_increased_to_normal
var is_increasing = false


func _ready():
	increase_volume_to_normal()


func increase_volume_to_normal():
	is_increasing = true
	tween.remove_all()
	tween.interpolate_property(self, "volume_db", volume_db, 0, 2)
	tween.start()


func decrease_volume_to_zero():
	is_increasing = false
	tween.remove_all()
	tween.interpolate_property(self, "volume_db", volume_db, -80, 2)
	tween.start()


func stop_bgm():
	decrease_volume_to_zero()
	yield(self, "volume_decreased_to_zero")
	stop()


func start_bgm(bgm_path):
	stream = load(bgm_path)
	play()
	increase_volume_to_normal()


func change_bgm(bgm_path):
	decrease_volume_to_zero()
	yield(self, "volume_decreased_to_zero")
	stream = load(bgm_path)
#	increase_volume_to_normal()


func _on_Tween_tween_all_completed():
	if is_increasing:
		emit_signal("volume_increased_to_normal")
	else:
		emit_signal("volume_decreased_to_zero")
