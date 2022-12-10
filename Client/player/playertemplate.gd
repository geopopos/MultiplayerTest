extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite

var state = "Idle"

func move_player(new_position, animation, flip_h):
	sprite.flip_h = flip_h
	global_position = new_position
	animationPlayer.play(animation)
