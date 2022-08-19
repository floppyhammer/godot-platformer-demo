extends Button
class_name GeneralButton


func _ready():
	connect("pressed", self, "_when_pressed")


func _when_pressed():
	$AnimPlayer.play("pressed")
	$PressSound.play()
