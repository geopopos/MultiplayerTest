extends Control

onready var label : Node = $CenterContainer/VBoxContainer/Label
onready var username_input : Node = $CenterContainer/VBoxContainer/Username
onready var userpassword_input : Node = $CenterContainer/VBoxContainer/Password
onready var login_button : Node = $CenterContainer/VBoxContainer/Button

func _on_Button_pressed():
	if username_input.text.empty() or userpassword_input.text.empty():
		print("please provide valid user id and password")
	else:
		login_button.disabled = true
		var username = username_input.text
		var password = userpassword_input.text
		print("attempting to login")
		Gateway.ConnectToServer(username, password)
#	if line_edit.text.empty():
#		label.text = "You must enter a name!"
#		return
#	else:
#		Server._connect_to_server()
#		Server.player_data = {"player_name": line_edit.text}
