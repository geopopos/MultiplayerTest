extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite

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
	animationPlayer.play(animation)


func take_damage():
	animationPlayer.play("Hurt")


func _on_hurt_animation_finished():
	print("other player hurt animation finished")
	visible = true
	animationPlayer.play("Idle")
	set_state(MOVE)
	

