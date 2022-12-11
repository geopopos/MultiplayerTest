extends YSort

onready var server = get_parent()
onready var Players = $Players

func _physics_process(delta):
	var world_state = server.player_state_collection.duplicate(true)
	var player_states = server.player_state_collection
	if not player_states.empty():
		for player_id in player_states:
			var player_state = player_states[player_id]
			var player_pos = player_state["P"]
			var player_fh = false
			if player_state.has("FH"):
				player_fh = player_state["FH"]
			var player = Players.get_node(str(player_id))
			player.update_player(player_pos, player_fh)
		
