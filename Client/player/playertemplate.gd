extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite
onready var healthBar = $HealthBar/ProgressBar

var player_state


var input_direction : Vector2

var animation_state : String = "Idle"

enum {
	MOVE,
	ATTACK,
	HURT
}

var state = MOVE setget set_state

func set_state(value):
	state = value


func _ready():
	animationPlayer.play("Idle")

func move_player(new_position, animation, flip_h):
	sprite.flip_h = flip_h
	global_position = new_position
	if not animationPlayer.current_animation == "Hurt":
		animationPlayer.play(animation)


func take_damage():
	animationPlayer.play("Hurt")


func _on_hurt_animation_finished():
	print("other player hurt animation finished")
	visible = true
	animationPlayer.play("Idle")
	set_state(MOVE)
	
func health(health, max_health):
	var healthPercent = health/float(max_health) * 100
	healthBar.value = healthPercent

func player_death():
	animationPlayer.play("Death")
	
	

