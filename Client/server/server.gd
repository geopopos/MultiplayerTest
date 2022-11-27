extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 3234


var network = NetworkedMultiplayerENet.new()
var selected_ip
var selected_port

var local_player_id = 0
sync var players = {}
sync var player_data = {}

onready var GameWorld = preload("res://world/world.tscn")
var gameWorld : Node

var Player = preload("res://player/player.tscn")

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
	
func _connected_ok():
	print("Successfully Connected To Server")
	register_player()
	rpc_id(1, "send_player_info", local_player_id, player_data)
	gameWorld = GameWorld.instance()
	add_child(gameWorld)
	var lobby = get_tree().get_root().get_node("Lobby")
	lobby.queue_free()

func _connected_failed():
	print("Failed To Connect Server")
	
func _server_disconnected():
	print("Disconnected from server")
	
func register_player():
	local_player_id = get_tree().get_network_unique_id()
	rpc_id(1, "fetch_players", local_player_id)
	
remote func receive_new_player(player_id, player_position, player_name):
	var player = Player.instance()
	
	player.name = str(player_id)
	player.position = player_position
	var label = player.get_node("PlayerName")
	label.text = player_name
	gameWorld.get_node("Players").add_child(player)
	if int(player_id) == int(local_player_id):
		player.set_network_master(int(local_player_id), true)
	print(player.is_network_master())
	if player.is_network_master():
		print("is network master")
		player.modulate = Color(0, 1, 0)

remote func receive_players(players):
	for p_id in players:
		var player = Player.instance()
		player.name = str(p_id)
		player.position = players[p_id]["position"]
		var label = player.get_node("PlayerName")
		label.text = players[p_id]["player_name"]
		gameWorld.get_node("Players").add_child(player)
		if int(p_id) == int(local_player_id):
			player.set_network_master(int(local_player_id), true)
