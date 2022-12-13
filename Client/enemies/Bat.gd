extends KinematicBody2D

onready var healthBar = $HealthBar/ProgressBar
onready var animationPlayer = $AnimationPlayer

func move_enemy(new_position):
	position = new_position

func health(health, max_health):
	var healthPercent = health/float(max_health) * 100
	healthBar.value = healthPercent
	

func death():
	animationPlayer.play("Death")
	healthBar.visible = false


func death_animation_complete():
	queue_free()

#func kill_enemy():
#	print("queue_free")
#	queue_free()
