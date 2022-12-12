extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1910
var cert = load("res://resources/certificate/X509_Certificate.crt")

var username
var password

onready var authenticationLabel = get_node("../Lobby/AuthenticationLabel")


func _ready():
	pass
	
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func ConnectToServer(_username, _password):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false) # add a third party cert and remove this before release
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	
	
func _on_connection_failed():
	print("failed to connect to login server")
	print("Pop-up server offline or something")
	get_node("../Lobby/CenterContainer/Login/Button").disabled = false
	# disbale login button below here

func _on_connection_succeeded():
	print("successfully connected to login server")
	RequestLogin()
	
	
func RequestLogin():
	print("Connecting to gateway to request login")
	rpc_id(1, "LoginRequest", username, password)
	username = ""
	password = ""
	
remote func ReturnLoginRequest(result, token, error, message):
	print("results received")
	if result == true:
		print("Authenticated Successfully")
		Server.token = token
		Server._connect_to_server()
	else:
		authenticationLabel.set_error_message(message)
		get_node("../Lobby/CenterContainer/Login/Button").disabled = false
	network.disconnect("connection_failed", self, "_on_connection_failed")
	network.disconnect("connection_succeeded", self, "_on_connection_succeeded")
		
