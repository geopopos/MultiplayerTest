extends Area2D

var player = null

func can_see_player():
	return player != null

func _on_PlayerDetectionZone_body_entered(body):
	if not can_see_player():
		player = body

func _on_PlayerDetectionZone_body_exited(body):
	if body == player:
		player = null
