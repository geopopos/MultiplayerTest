extends KinematicBody2D

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var Server : Node

enum {
	IDLE,
	WANDER,
	CHASE,
	FREEZE
}

var state = CHASE
var spawner

onready var playerDetectionZone = $PlayerDetectionZone
onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite
onready var wanderController = $WanderController

func _ready():
	Server = get_tree().get_root().get_node("Server")

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wanderController.target_position, delta)
			wanderController.update_target_position()


			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
		CHASE:
			var players = playerDetectionZone.players
			var player = null
			var closest = 9000000
			for p_name in players: 
				var distance2player = position.distance_to(players[p_name].position)
				if distance2player < closest:
					player = players[p_name]
					closest = distance2player
			if player != null and Server.check_for_player(int(player.name)):
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
		FREEZE:
			animationPlayer.stop()
			velocity = Vector2.ZERO

	velocity = move_and_slide(velocity)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func accelerate_towards_point(position, delta):
	var direction = global_position.direction_to(position)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))


func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
