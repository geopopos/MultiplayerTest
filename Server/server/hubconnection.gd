extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1912

onready var gameserver = get_node("/root/Server")

func _ready():
	ConnectToServer()
	
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func ConnectToServer():
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connnection_failed")
	network.connect("connection_succeeded", self, "_on_connnection_succeeded")
	
func _on_connection_failed():
	print("Failed to connect to Game Server Hub")

func _on_connection_succeeded():
	print("Successfully connected to Game Server Hub")

remote func ReceiveLoginToken(token):
	gameserver.expected_tokens.append(token)
