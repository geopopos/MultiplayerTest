extends Control

# Login Nodes
onready var label : Node = $CenterContainer/Login/Label
onready var username_input : Node = $CenterContainer/Login/Username
onready var userpassword_input : Node = $CenterContainer/Login/Password
onready var login_button : Node = $CenterContainer/Login/Button

func _on_Button_pressed():
	if username_input.text.empty() or userpassword_input.text.empty():
		print("please provide valid user id and password")
	else:
		login_button.disabled = true
		var username = username_input.text
		var password = userpassword_input.text
		Server.player_data["player_name"] = username
		print("attempting to login")
		Gateway.ConnectToServer(username, password)
#	if line_edit.text.empty():
#		label.text = "You must enter a name!"
#		return
#	else:
#		Server._connect_to_server()
#		Server.player_data = {"player_name": line_edit.text}


func _on_CreateAccount_pressed():
	OS.shell_open("http://localhost:8000/register")
