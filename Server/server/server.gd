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
	
remote func send_player_info(id, player_data):
	players[id] = player_data
	var playerSpawn = gameWorld.get_node("PlayerSpawn")
	var player = Player.instance()
	player.name = str(id)
	var label = player.get_node("PlayerName")
	label.text = player_data["player_name"]
	gameWorld.add_child(player)
	player.position = playerSpawn.position
	rpc("receive_new_player", id, player.position, player_data["player_name"])
	
