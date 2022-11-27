extends KinematicBody2D

const MAXSPEED: int = 80
var velocity : Vector2 = Vector2.ZERO
var Server : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	Server = get_tree().get_root().get_node("Server")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func player_movement(input_vector):
	velocity = move_and_slide(input_vector * MAXSPEED)
	Server.update_player_position(name, position)
