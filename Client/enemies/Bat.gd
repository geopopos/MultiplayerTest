extends KinematicBody2D

onready var healthBar = $HealthBar/ProgressBar

func move_enemy(new_position):
	position = new_position

func health(health, max_health):
	var healthPercent = health/float(max_health) * 100
	healthBar.value = healthPercent
	
	

#func kill_enemy():
#	print("queue_free")
#	queue_free()
