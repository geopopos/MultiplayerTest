extends YSort

onready var Player = preload("res://player/player.tscn")
onready var PlayerTemplate = preload("res://player/playertemplate.tscn")
onready var players = $Players

var last_world_state = 0
var world_state_buffer = []
const interpolation_offset = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn_new_player(player_id, player_position, player_name, flip_h):
	if not players.has_node(str(player_id)):
		var player = Player.instance()
		
		player.name = str(player_id)
		player.position = player_position
		var label = player.get_node("PlayerName")
		var sprite = player.get_node("Sprite")
		sprite.flip_h = flip_h
		label.text = player_name
		if int(player_id) == get_tree().get_network_unique_id():
			player.set_network_master(int(get_tree().get_network_unique_id()), true)
			player.get_node("Camera2D").current = true
		else:
			player = PlayerTemplate.instance()
			player.name = str(player_id)
			player.position = player_position
			sprite.flip_h = flip_h
			label.text = player_name
		get_node("Players").add_child(player)
		if player.is_network_master():
			player.get_node("PlayerName").self_modulate = Color(0, 1, 0)
		
func remove_player(player_id):
	get_node("Players").remove_child(get_node("Players").get_node(str(player_id)))

func update_world_state(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
	
	
func _physics_process(delta):
	var render_time = Server.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2: # has future state
			var interpolation_factor = float(render_time - world_state_buffer[1].T) / float(world_state_buffer[2].T - world_state_buffer[1].T)
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if players.has_node(str(player)):
					var new_position = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
					players.get_node(str(player)).move_player(new_position)	
				else:
					spawn_new_player(player, world_state_buffer[2][player]["P"], Server.players[int(player)]["player_name"], false)
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = float(render_time - world_state_buffer[0].T) / float(world_state_buffer[1].T - world_state_buffer[0].T) - 1.00
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if players.has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"]) * extrapolation_factor
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					players.get_node(str(player)).move_player(new_position)	
#func update_world_state_OLD(world_state):
#	# Buffer
#	# Interpolation
#	# Extrapolation
#	# Rubber Banding
#	if world_state["T"] > last_world_state: # again we cannot be guaranteed the order in which packets come in
#		last_world_state = world_state["T"]
#		world_state.erase("T")
#		world_state.erase(int(get_tree().get_network_unique_id()))
#		for player in world_state.keys():
#			if players.has_node(str(player)):
#				var new_position = lerp(world_state_buffer[0][player]["P"], world_state[1][player]["P"], interpolation_factor)
#				players.get_node(str(player)).move_player(new_position)
#			else:
#				spawn_new_player(player, world_state[player]["P"], Server.players[int(player)]["player_name"], false)
		
		
