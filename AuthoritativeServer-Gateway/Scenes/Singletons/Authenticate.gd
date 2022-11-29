extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1911

func _ready():
	ConnectToServer()
	
func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	
func _on_connection_failed():
	print("failed to connect to authentication server")

func _on_connection_succeeded():
	print("Successfully connected to authentication server")

func AuthenticatePlayer(username, password, player_id):
	print("sending authentication request")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)
	
remote func AuthenticationResults(result, player_id):
	print("results received and replying to players login request")
	Gateway.ReturnLoginRequest(result, player_id)
