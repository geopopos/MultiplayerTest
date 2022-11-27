extends KinematicBody2D

var MAXSPEED : int = 80
var velocity : Vector2 = Vector2.ZERO

var input_direction : Vector2

func _process(delta):
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if is_moving() and is_network_master():
			Server.process_player_input(input_direction)
			velocity = move_and_slide(input_direction * MAXSPEED)

func is_moving():
	return input_direction != Vector2.ZERO
