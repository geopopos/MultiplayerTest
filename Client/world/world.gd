extends YSort

onready var Player = preload("res://player/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn_new_player(player_id, player_position, player_name, flip_h):
	var player = Player.instance()
	
	player.name = str(player_id)
	player.position = player_position
	var label = player.get_node("PlayerName")
	var sprite = player.get_node("Sprite")
	sprite.flip_h = flip_h
	label.text = player_name
	get_node("Players").add_child(player, true)
	if int(player_id) == get_tree().get_network_unique_id():
		player.set_network_master(int(get_tree().get_network_unique_id()), true)
		player.get_node("Camera2D").current = true
	print(player.is_network_master())
	if player.is_network_master():
		print("is network master")
		player.get_node("PlayerName").self_modulate = Color(0, 1, 0)

func remove_player(player_id):
	get_node("Players").remove_child(get_node("Players").get_node(str(player_id)))
