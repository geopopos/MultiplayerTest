extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1911
var max_servers = 5
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
	if not PlayerData.PlayerIDs.has(username):
		print("User is not recognized")
		result = false
	elif not PlayerData.PlayerIDs[username].Password == password:
		print("incorrect password")
		result = false
	# eventually add a check here to see if the player is already logged in
	else:
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
		
	