extends Node

func set_up_player(id, label, player, gameWorld, playerSpawn, player_data):
	player.name = str(id)
	label.text = player_data["player_name"]
	gameWorld.get_node("Players").add_child(player)
	player.position = playerSpawn.position
	player_data["position"] = player.position
	return player_data
