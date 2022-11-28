extends KinematicBody2D

const MAXSPEED: int = 80
var velocity : Vector2 = Vector2.ZERO
var Server : Node

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var hitboxCollision = $HitBox/CollisionShape2D

enum {
	MOVE,
	ATTACK
}

var state = MOVE setget set_state

# Called when the node enters the scene tree for the first time.
func _ready():
	Server = get_tree().get_root().get_node("Server")

func player_movement(input_vector):
	if state == MOVE:
		velocity = move_and_slide(input_vector * MAXSPEED)
		var flipped = input_vector.x < 0
		sprite.flip_h = flipped
		if flipped:
			hitboxCollision.position = Vector2(-12.5,-2)
		else:
			hitboxCollision.position = Vector2(12.5,-2)
		animationPlayer.play("Walking")
		Server.update_player_position(name, position, sprite.flip_h, "Walking")
	
func set_idle():
	animationPlayer.play("Idle")
	
func set_state(value):
	state = value
	
func start_attack():
	set_state(ATTACK)
	animationPlayer.play("Attack")
	
func _on_attack_animation_finished():
	set_state(MOVE)
	animationPlayer.play("Idle")

func _on_HurtBox_area_entered(area):
	print(str(name) + " Got An Ouchie")
