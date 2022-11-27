extends Control

onready var label : Node = $CenterContainer/VBoxContainer/Label
onready var line_edit : Node = $CenterContainer/VBoxContainer/LineEdit

func _on_Button_pressed():
	if line_edit.text.empty():
		label.text = "You must enter a name!"
		return
	else:
		Server._connect_to_server()
		Server.player_data = {"player_name": line_edit.text}
