extends Area2D

var players = {}

func can_see_player():
	return not players.empty()

func _on_PlayerDetectionZone_body_entered(body):
		players[body.name] = body

func _on_PlayerDetectionZone_body_exited(body):
	if players.has(body.name):
		players.erase(body.name)
