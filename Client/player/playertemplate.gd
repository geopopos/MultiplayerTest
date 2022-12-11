extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite

var player_state

func move_player(new_position, animation, flip_h):
	sprite.flip_h = flip_h
	global_position = new_position
	animationPlayer.play(animation)


func take_damage():
	animationPlayer.play("Hurt")
