extends Node2D

"""
Belletins triger dialog while signs triger notification.
"""

export var content : String


func _on_Bulletin_body_entered(body):
	if body.is_in_group("player"):
		Global.hud.add_notification(content)
