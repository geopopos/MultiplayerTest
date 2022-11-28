extends KinematicBody2D

var MAXSPEED : int = 80
var velocity : Vector2 = Vector2.ZERO

var move_on : bool = false

onready var sprite : Node = $Sprite
onready var animationPlayer : Node = $AnimationPlayer

var input_direction : Vector2

func _process(_delta):
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if is_moving() and is_network_master():
			move_on = true
			animationPlayer.play("Walking")
			sprite.flip_h = input_direction.x < 0
			Server.process_player_input(input_direction)
			velocity = move_and_slide(input_direction * MAXSPEED)
		elif not is_moving() and move_on:
			animationPlayer.play("Idle")
			Server.set_player_idle()
			move_on = false

func is_moving():
	return input_direction != Vector2.ZERO
