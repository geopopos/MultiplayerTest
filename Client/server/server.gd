extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 3234


var network = NetworkedMultiplayerENet.new()
var selected_ip
var selected_port

var token
var verification_result = false

var local_player_id = 0
sync var players = {}
sync var player_data = {}

onready var GameWorld = preload("res://world/world.tscn")
var gameWorld : Node

var Player = preload("res://player/player.tscn")
var gamePlayers : Node

onready var TileMapBlank = preload("res://tilemap.tscn")

var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0

func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connection_failed", self, "_connected_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _connect_to_server():
	get_tree().connect("connected_to_server", self, "_connected_ok")
	network.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(network)

func _player_connected(id):
	print("Player " + str(id) + " Connected")

func _player_disconnected(id):
	print("Player " + str(id) + " Disconnected")
	
# Clock Synchronization
func _connected_ok():
	print("Successfully Connected To Server")
	rpc_id(1, "fetch_server_time", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "determine_latency")
	self.add_child(timer)
	
func determine_latency():
	rpc_id(1, "determine_latency", OS.get_system_time_msecs())
	
remote func return_latency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time)/2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size() -1,-1,-1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		latency_array.clear()
	
remote func return_server_time(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency

func _connected_failed():
	print("Failed To Connect Server")
	
func _server_disconnected():
	print("Disconnected from server")
	
func register_player():
	local_player_id = get_tree().get_network_unique_id()
	rpc_id(1, "fetch_players")
	
remote func receive_new_player(player_id, player_position, player_name):
	print("received new player")
	gameWorld.spawn_new_player(player_id, player_position, player_name, false)

remote func set_up_world(players, grassTilemapDict, layer1TilemapDict, tileset):
	# write tileset to file
	var file = File.new()
	file.open("res://world/worldtileset.tres", File.WRITE)
	file.store_string(tileset)
	file.close()
	
	## add tilemaps by highest to lowest (furthest back map usually background should be loaded last)
	# create layer1tilemap
	var layer1TileMap = TileMapBlank.instance()
	layer1TileMap.set_tileset(load("res://world/worldtileset.tres"))
	gameWorld.add_child(layer1TileMap)
	gameWorld.move_child(layer1TileMap, 0)
	for row_key in layer1TilemapDict:
		var cell = Vector2(row_key, 0)
		for column_key in layer1TilemapDict[row_key]:
			cell.y = column_key
			var cellData = layer1TilemapDict[row_key][column_key]
			var tile_id = cellData["tile_id"]
			var auto_tile_coord = cellData["auto_tile_coord"]
			layer1TileMap.set_cell(cell.x, cell.y, tile_id, false, false, false, auto_tile_coord)
	
	# create grasstilemap
	var grassTileMap = TileMapBlank.instance()
	grassTileMap.set_tileset(load("res://world/worldtileset.tres"))
	gameWorld.add_child(grassTileMap)
	gameWorld.move_child(grassTileMap, 0)
	for row_key in grassTilemapDict:
		var cell = Vector2(row_key, 0)
		for column_key in grassTilemapDict[row_key]:
			cell.y = column_key
			var cellData = grassTilemapDict[row_key][column_key]
			var tile_id = cellData["tile_id"]
			grassTileMap.set_cellv(cell, tile_id)
			
			
	

remote func receive_players(players):
	print("receive players")
	for p_id in players:
		print("Spawn Players")
		var player_name = players[p_id]["player_name"]
		var player_position = players[p_id]["position"]
		var flip_h = players[p_id]["flip_h"]
		gameWorld.spawn_new_player(p_id, player_position, player_name, flip_h)

remote func remove_player(player_id):
	# created so that the interpolation function in the world physics process won't respawn a player that just disconnected
	# this happens because the player may still have position data in future states, but we don't want to respawn them if they've disconnected
	yield(get_tree().create_timer(0.2), "timeout")
	gameWorld.remove_player(player_id)

# Player Movement
func send_player_state(player_state):
	rpc_unreliable_id(1, "receive_player_state", player_state)
	
remote func receive_world_state(world_state):
	if has_node("World"):
		gameWorld.update_world_state(world_state)

# Old Player movement System
#func process_player_input(input_vector):
#	rpc_unreliable_id(1, "process_player_input", local_player_id, input_vector)
#
#remote func update_player_position(id, position, flip_h, animation):
#	var player = gamePlayers.get_node(str(id))
#	player.position = position
#	player.get_node("Sprite").flip_h = flip_h
#	player.get_node("AnimationPlayer").play(animation)
#
#func set_player_idle():
#	rpc_id(1, "set_player_idle", local_player_id)
#
#remote func set_player_animation(id, animation):
#	var player = gamePlayers.get_node(str(id))
#	player.get_node("AnimationPlayer").play(animation)
	
## combat system
func send_player_attacked():
	rpc_id(1, "player_triggered_attack", local_player_id)
	
remote func set_player_knockback(id, global_position):
	var player = gamePlayers.get_node(str(id))
	player.global_position = global_position
	player.take_damage()

remote func receive_player_attack(id):
	print("received_player_attack")
	var player = gamePlayers.get_node(str(id))
	player.set_state(1)
	

## player verification system
remote func FetchToken():
	rpc_id(1, "ReturnToken", token)

remote func ReturnTokenVerificationResults(result):
	print("ReturnTokenVerificationResults Called")
	if result == true:
		# run logic to start game
		verification_result = result
		print("Successful Token Verification")
		register_player()
		player_data 
		rpc_id(1, "send_player_info", player_data)
		gameWorld = GameWorld.instance()
		add_child(gameWorld)
		gamePlayers = gameWorld.get_node("Players")
		var lobby = get_tree().get_root().get_node("Lobby")
		lobby.queue_free()
	else:
		print("Login, failed please try again")
		var lobby = get_tree().get_root().get_node("Lobby")
		lobby.get_node("CenterContainer/Login/Button").disabled = false
		
