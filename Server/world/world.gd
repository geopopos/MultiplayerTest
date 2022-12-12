extends YSort

onready var server = get_parent()
onready var Players = $Players
onready var enemies = $Enemies

var enemy_list = {}

var rng = RandomNumberGenerator.new()

func _physics_process(delta):
	var world_state = server.player_state_collection.duplicate(true)
	var player_states = server.player_state_collection
	if not player_states.empty():
		for player_id in player_states:
			var player_state = player_states[player_id]
			var player_pos = player_state["P"]
			var player_fh = false
			if player_state.has("FH"):
				player_fh = player_state["FH"]
			var player = Players.get_node(str(player_id))
			player.update_player(player_pos, player_fh)
	for enemy in enemy_list:
		enemy_list[enemy]["EnemyLocation"] = enemies.get_node(str(enemy)).position
		
func add_enemy(enemy):
	enemies.add_child(enemy)
	enemy_list[enemy.get_instance_id()] = {"EnemyType": "Bat", "EnemyLocation": enemy.position, "EnemyHealth": 2, "EnemyMaxHealth": 2}
	
