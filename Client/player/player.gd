extends KinematicBody2D

var MAXSPEED : int = 80
var velocity : Vector2 = Vector2.ZERO

var move_on : bool = false

onready var sprite : Node = $Sprite
onready var animationPlayer : Node = $AnimationPlayer

var input_direction : Vector2

enum {
	MOVE,
	ATTACK
}

var state = MOVE setget set_state

func set_state(value):
	state = value

func _process(_delta):
	if is_network_master():
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		match state:
			MOVE:
				move_state()
			ATTACK:
				attack_state()
	else:
		pass

	
	
func move_state():
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
	
	if Input.is_action_just_pressed("attack"):
		Server.send_player_attacked()
		set_state(ATTACK)

func is_moving():
	return input_direction != Vector2.ZERO

func attack_state():
	# stops weird slide after attack
	velocity = Vector2.ZERO
	animationPlayer.play("Attack")
	
func attack_animation_finished():
	set_state(MOVE)
	animationPlayer.play("Idle")
