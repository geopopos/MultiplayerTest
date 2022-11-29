extends Node

var network = NetworkedMultiplayerENet.new()
var port = 3234
var max_players = 100

var expected_tokens = []

var players = {}

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
	
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")
	
	print("server started")

func _player_connected(player_id):
	print("Player " + str(player_id) + " Connected")
	player_verification_process.start(player_id)

func _player_disconnected(player_id):
	print("Player " + str(player_id) + " Disconnected")
	var world_players = gameWorld.get_node("Players")
	world_players.get_node(str(player_id)).queue_free()
	players.erase(player_id)
	get_node(str(player_id)).queue_free()
	rset("players", players)
	rpc("remove_player", player_id)
	
remote func send_player_info(id, player_data):
	var playerSpawn = gameWorld.get_node("PlayerSpawn")
	var player = Player.instance()
	var label = player.get_node("PlayerName")
	player_data = playerSpawning.set_up_player(id, label, player, gameWorld, playerSpawn, player_data)
	players[id] = player_data
	rset("players", players)
	rpc_id(id, "set_up_world", players, grassTilemapDict, layer1TilemapDict, tileset)
	rpc("receive_new_player", id, player.position, player_data["player_name"])

remote func fetch_players(id):
	rpc_id(id, "receive_players", players)
	

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
	
func send_player_damage(name, health, global_position):
	# add updating player health here as well
	players[int(name)]["health"] = health
	rset("players", players)
	rpc("set_player_knockback", name, global_position)
