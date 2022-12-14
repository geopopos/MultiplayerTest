extends Node

var network = NetworkedMultiplayerENet.new()
var port = 3234
var max_players = 100

var expected_tokens = []

var players = {}
var player_state_collection = {}

onready var player_verification_process = get_node("PlayerVerification")
onready var GameWorld = preload("res://world/world.tscn")
var gameWorld : Node
var gamePlayers : Node

onready var Player = preload("res://player/player.tscn")

onready var playerSpawning : Node = $PlayerSpawning

var grassTilemap : Node
var layer1Tilemap : Node
var grassTilemapDict: Dictionary
var layer1TilemapDict: Dictionary
var tileset

func _ready():
	start_server()
	gameWorld = GameWorld.instance()
	gameWorld.name = "WorldMap"
	add_child(gameWorld)
	gamePlayers = gameWorld.get_node("Players")
	grassTilemap = gameWorld.get_node("Grass")
	var grassTilemapCells = grassTilemap.get_used_cells()
	for cell in grassTilemapCells:
		if not grassTilemapDict.has(cell.x):
			grassTilemapDict[cell.x] = {}
		var tile_id = grassTilemap.get_cellv(cell)
		grassTilemapDict[cell.x][cell.y] = {
				"position": cell,
				"tile_id": tile_id
			}
	layer1Tilemap = gameWorld.get_node("Layer1")
	var layer1TilemapCells = layer1Tilemap.get_used_cells()
	for cell in layer1TilemapCells:
		if not layer1TilemapDict.has(cell.x):
			layer1TilemapDict[cell.x] = {}
		var tile_id = layer1Tilemap.get_cellv(cell)
		layer1TilemapDict[cell.x][cell.y] = {
				"position": cell,
				"tile_id": tile_id,
				"auto_tile_coord": layer1Tilemap.get_cell_autotile_coord(cell.x, cell.y)
			}
	# load tileset file data to send
	var file = File.new()
	file.open("res://world/worldtileset.tres", File.READ)
	tileset = file.get_as_text()
	file.close()

func check_for_player(player_id):
	return player_state_collection.has(player_id)
	
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")
	
	print("server started")

func _player_connected(player_id):
	print("Player " + str(player_id) + " Connected")
	player_verification_process.Start(player_id)

func _player_disconnected(player_id):
	print("Player " + str(player_id) + " Disconnected")
	var world_players = gameWorld.get_node("Players")
	if  world_players.has_node(str(player_id)):
		world_players.get_node(str(player_id)).queue_free()
		players.erase(player_id)
		player_state_collection.erase(player_id)
	get_node(str(player_id)).queue_free()
	rset("players", players)
	rpc("remove_player", player_id)
	
remote func send_player_info(player_data):
	var id = get_tree().get_rpc_sender_id()
	var playerSpawn = gameWorld.get_node("PlayerSpawn")
	var player = Player.instance()
	var label = player.get_node("PlayerName")
	player_data = playerSpawning.set_up_player(id, label, player, gameWorld, playerSpawn, player_data)
	players[id] = player_data
	print(player.stats.health)
	player_state_collection[id] = {"T": OS.get_system_time_msecs(), "P": playerSpawn.position, "health": player.stats.health, "max_health": player.stats.max_health}
	rset("players", players)
	rpc_id(id, "set_up_world", players, grassTilemapDict, layer1TilemapDict, tileset)
	print("Player Name: " + player_data["player_name"])
	print("player being sent to clients")
	rpc("receive_new_player", id, player.position, player_data["player_name"])

remote func fetch_players():
	var id = get_tree().get_rpc_sender_id()
	rpc_id(id, "receive_players", players)
	
func kill_player(player_id):
	rpc("kill_player", player_id)
	
func send_player_health(player_id, health, max_health):
	print("send player health")
	rpc_id(player_id, "receive_player_health", health, max_health)

remote func receive_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]: # we cannot be guaranteed the latest incoming packet is in fact the newest, so we want to check the timestamp of the state before pushing it to the players current player_state
			for key in player_state.keys():
				player_state_collection[player_id][key] = player_state[key]
		else:
			for key in player_state.keys():
				player_state_collection[player_id][key] = player_state[key]

func send_world_state(world_state):
	rpc_unreliable("receive_world_state", world_state)

remote func process_player_input(id, input_vector):
	var player = gamePlayers.get_node(str(id))
	player.player_movement(input_vector)
	
func update_player_position(id, position, flip_h, animation):
	var player = players[int(id)]
	player["position"] = position
	player["flip_h"] = flip_h
	rset("players", players)
	rpc_unreliable("update_player_position", id, position, flip_h, animation)

remote func set_player_idle(id):
	var player = gamePlayers.get_node(str(id))
	player.set_idle()
	rpc("set_player_animation", id, "Idle")


## combat code
remote func player_triggered_attack(id):
	var player = gamePlayers.get_node(str(id))
	player.start_attack()
	rpc("receive_player_attack", id)

func set_player_animation(id, animation):
	print("Set player animation to idle")
	print(id)
	print(player_state_collection)
	player_state_collection[id]["A"] = "Idle"
	print(player_state_collection)

func send_player_damage(name, health, global_position, max_health):
	print("set player hurt")
	# add updating player health here as well
	players[int(name)]["health"] = health
	rset("players", players)
	player_state_collection[int(name)]["P"] = global_position
	player_state_collection[int(name)]["A"] = "Hurt"
	rpc_id(int(name), "set_player_knockback", name, global_position, health, max_health)
	
	
remote func respawn_player(player_id):
	var player = gamePlayers.get_node(str(player_id))
	player.respawn_player()
	

func kill_enemy(enemy_name):
	print("Kill enemy " + enemy_name)
	rpc("kill_enemy", enemy_name)

# Player Verification
func _on_TokenExpiration_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens.empty():
		pass
	else:
		for i in range(expected_tokens.size(), -1, -1, -1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)
		print("Expected Tokens:")
		print(expected_tokens)
		
func FetchToken(player_id):
	rpc_id(player_id, "FetchToken")

remote func ReturnToken(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.Verify(player_id, token)
	
func ReturnTokenVerificationResults(player_id, result):
	rpc_id(player_id, "ReturnTokenVerificationResults", result)
	
	
# Clock Synchronization
remote func fetch_server_time(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_server_time", OS.get_system_time_msecs(), client_time)


remote func determine_latency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_latency", client_time)
	
	

