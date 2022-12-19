extends KinematicBody2D

var MAXSPEED : int = 80
var velocity : Vector2 = Vector2.ZERO

var move_on : bool = false

onready var sprite : Node = $Sprite
onready var animationPlayer : Node = $AnimationPlayer
onready var stats : Node = $Stats

var input_direction : Vector2

var animation_state : String = "Idle"

enum {
	MOVE,
	ATTACK,
	HURT,
	DEATH
}

var state = MOVE setget set_state
var player_state

func set_state(value):
	state = value

func _physics_process(_delta):
	if is_network_master():
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		DEATH:
			death_state()
	DefinePlayerState()
	
func DefinePlayerState():
	player_state = {"T": Server.client_clock, "P": position, "A": animation_state, "FH": sprite.flip_h}
	Server.send_player_state(player_state)
	
func move_state():
	if is_moving() and is_network_master():
		move_on = true
		animationPlayer.play("Walking")
		animation_state = "Walking"
		sprite.flip_h = input_direction.x < 0
#		Server.process_player_input(input_direction)
		velocity = move_and_slide(input_direction * MAXSPEED)
	elif not is_moving() and move_on:
		animationPlayer.play("Idle")
		animation_state = "Idle"
#		Server.set_player_idle()
		move_on = false
	
	if Input.is_action_just_pressed("attack") and is_network_master():
		Server.send_player_attacked()
		set_state(ATTACK)

func is_moving():
	return input_direction != Vector2.ZERO

func attack_state():
	# stops weird slide after attack
	velocity = Vector2.ZERO
	animationPlayer.play("Attack")
	animation_state = "Attack"
	
func player_death():
	animationPlayer.play("Death")
	state = DEATH
	
func death_state():
	if Input.is_action_just_pressed("attack") and is_network_master():
		respawn()
		
func respawn():
	state = MOVE
	Server.respawn_player()
	stats.stats_reset()
	
func _on_death_animation_finished():
	animationPlayer.stop()
	
func attack_animation_finished():
	set_state(MOVE)
	animationPlayer.play("Idle")
	animation_state = "Idle"

func take_damage():
	set_state(HURT)
	animationPlayer.play("Hurt")
	animation_state = "Hurt"
	
func on_hurt_animation_finished():
	animationPlayer.play("Idle")
	animation_state = "Idle"
	set_state(MOVE)
	
func move_player(new_position, animation, flip_h):
	pass
	
func health(health, max_health):
	stats.health = health
	stats.max_health = max_health
	var healthPercent = health/float(max_health) * 100

func _on_Stats_no_health():
	# run player death sequence
	# give player ability to respawn <-- In death sequence?
	pass
