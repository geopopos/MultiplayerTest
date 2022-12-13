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
			server.player_state_collection[player_id]["health"] = player.stats.health
			server.player_state_collection[player_id]["max_health"] = player.stats.max_health
			player.update_player(player_pos, player_fh)
	for enemy in enemy_list:
		if enemies.has_node(str(enemy)):
			enemy_list[enemy]["EnemyLocation"] = enemies.get_node(str(enemy)).position
			enemy_list[enemy]["EnemyHealth"] = enemies.get_node(str(enemy)).stats.health
			enemy_list[enemy]["EnemyMaxHealth"] = enemies.get_node(str(enemy)).stats.max_health
		
func add_enemy(enemy):
	enemies.add_child(enemy)
	enemy_list[enemy.get_instance_id()] = {"EnemyType": "Bat", "EnemyLocation": enemy.position, "EnemyHealth": enemy.stats.health, "EnemyMaxHealth": enemy.stats.max_health}
	
func remove_enemy(enemy_name):
	var enemy = enemies.get_node(enemy_name)
	enemies.remove_child(enemy)
	enemy_list.erase(int(enemy_name))
	server.kill_enemy(enemy_name)
	enemy.queue_free()
