extends Node

var world_state = {}

func _physics_process(delta):
	if not get_parent().player_state_collection.empty():
		world_state = get_parent().player_state_collection.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase("T")
		world_state["T"] = OS.get_system_time_msecs()
		# Verifications
		# Anti-cheats
		# Cuts (Chunking / maps)
		# Physics checks
		# Anything else you have to do
		get_parent().send_world_state(world_state)
