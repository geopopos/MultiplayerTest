extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1911
var max_servers = 5

onready var httpRequest = $HTTPRequest

func _ready():
	StartServer()

func StartServer():
	network.create_server(port, max_servers) 
	get_tree().set_network_peer(network)
	print("Authentication server started")
	network.connect("peer_connected", self, "_peer_connected")
	network. connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(gateway_id):
	print("Gateway " + str(gateway_id) + " Connected" )
	
func _peer_disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " Disconnected")

remote func AuthenticatePlayer(username, password, player_id):
	var token
	print("Authentication Request Received")
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	print("Starting Authentication")
	var body = {
		"username": username,
		"password": password,
		"token": token,
		"gateway_id": str(gateway_id),
		"player_id": str(player_id)
	}
	var query = JSON.print(body)
	var headers = ["Content-Type: application/json"]
	httpRequest.request("http://localhost:8000/login_user", headers, false, HTTPClient.METHOD_POST, query)
	
		
	


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result.has("error"):
		if json.result["error"] == "user_not_exists":
			print("User is not recognized")
			result = false
		if json.result["error"] == "incorrect_password":
			print("incorrect password")
			result = false
	else:
		var token = json.result["token"]
		var gateway_id = int(json.result["gateway_id"])
		var player_id = int(json.result["player_id"])
		result = true
		randomize()
		var random_number = randi()
		print(random_number)
		var hashed = str(random_number).sha256_text()
		print(hashed)
		var timestamp = str(OS.get_unix_time())
		print(timestamp)
		token = hashed + timestamp
		print(token)
		var gameserver = "GameServer1"
		GameServers.DistributeLoginToken(token, gameserver)
		print("authentication result send to gateway server")
		rpc_id(gateway_id, "AuthenticationResults", result, player_id, token)
