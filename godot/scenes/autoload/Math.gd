extends Node


func rot2vec(rot : float) -> Vector2:
	return Vector2(cos(rot), sin(rot))
