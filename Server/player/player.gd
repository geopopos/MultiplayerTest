extends KinematicBody2D

const MAXSPEED: int = 80
var velocity : Vector2 = Vector2.ZERO
var Server : Node

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	Server = get_tree().get_root().get_node("Server")

func player_movement(input_vector):
	velocity = move_and_slide(input_vector * MAXSPEED)
	sprite.flip_h = input_vector.x < 0
	animationPlayer.play("Walking")
	Server.update_player_position(name, position, sprite.flip_h, "Walking")
	
func set_idle():
	animationPlayer.play("Idle")
	
