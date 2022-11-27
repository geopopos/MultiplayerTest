extends Node

var network = NetworkedMultiplayerENet.new()
var port = 3234
var max_players = 4

var players = {}

onready var GameWorld = preload("res://world/world.tscn")
var gameWorld : Node

onready var Player = preload("res://player/player.tscn")

func _ready():
	start_server()
	gameWorld = GameWorld.instance()
	add_child(gameWorld)
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")
	
	print("server started")

func _player_connected(player_id):
	print("Player " + str(player_id) + " Connected")

func _player_disconnected(player_id):
	print("Player " + str(player_id) + " Disconnected")
#	var world_players = gameWorld.get_node("Players")
#	world_players.get_node(str(player_id)).queue_free()
# also pop player from players dictionary
# also send and rpc call to send that player was disconnected
	
remote func send_player_info(id, player_data):
	var playerSpawn = gameWorld.get_node("PlayerSpawn")
	var player = Player.instance()
	player.name = str(id)
	var label = player.get_node("PlayerName")
	label.text = player_data["player_name"]
	gameWorld.get_node("Players").add_child(player)
	player.position = playerSpawn.position
	player_data["position"] = player.position
	players[id] = player_data
	rset("players", players)
	# finish set up of this RPC CALL
	rpc_id(id, "set_up_world", players)
	rpc("receive_new_player", id, player.position, player_data["player_name"])

remote func fetch_players(id):
	rpc_id(id, "receive_players", players)
	
