extends Node

func set_up_player(id, label, player, gameWorld, playerSpawn, player_data):
	print("setting up player")
	player.name = str(id)
	label.text = player_data["player_name"]
	gameWorld.get_node("Players").add_child(player, true)
	player.position = playerSpawn.position
	player_data["position"] = player.position
	player_data["flip_h"] = false
	player_data["health"] = player.stats.health
	return player_data
