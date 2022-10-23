extends KinematicBody2D

"""
This is the base of all NPCs.
"""

signal player_come_close
signal player_goes_away


func _ready():
	$Bubble.hide()


func interact():
	pass


func _on_ReactionArea_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("player_come_close")
		$Bubble.show()


func _on_ReactionArea_body_exited(body):
	if body.is_in_group("player"):
		emit_signal("player_goes_away")
		$Bubble.hide()
