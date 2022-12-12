extends Node2D

export(int) var wander_range = 32

var start_position
var target_position

var timer

func _ready():
	timer = $Timer
	start_position = global_position
	target_position = global_position
	print(start_position)
	print(target_position)

func update_target_position():
	var target_vector = Vector2(rand_range(-wander_range,wander_range), rand_range(-wander_range,wander_range))
	target_position = start_position + target_vector

func get_time_left():
	return timer.time_left
	
func start_wander_timer(duration):
	timer.start(duration)

func _on_Timer_timeout():
	update_target_position()
