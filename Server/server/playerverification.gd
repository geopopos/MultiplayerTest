extends Node

onready var PlayerContainer = preload("res://player/playercontainer.tscn")

func start(player_id):
	
	CreatePlayerContainer(player_id)

func CreatePlayerContainer(player_id):
	var new_player_container = PlayerContainer.instance()
	new_player_container.name = str(player_id)
	get_parent().add_child(new_player_container, true)
	var player_container = get_node("../" + str(player_id))
	FillPlayerContainer(player_container)
	
func FillPlayerContainer(player_container):
	player_container.player_stats = Serverdata.test_data.Stats
