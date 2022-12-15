extends KinematicBody2D

const MAXSPEED: int = 80
var velocity : Vector2 = Vector2.ZERO
var Server : Node



var receives_knockback = true
var knockback_multiplier = 15

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var hitboxCollision = $HitBox/CollisionShape2D
onready var hurtboxCollision = $HurtBox/CollisionShape2D
onready var hurtBoxDisabledTimer = $HurtBoxDisabledTimer
onready var stats = $Stats

enum {
	MOVE,
	ATTACK
}

var state = MOVE setget set_state

# Called when the node enters the scene tree for the first time.
func _ready():
	Server = get_tree().get_root().get_node("Server")

#func player_movement(input_vector):
#	if state == MOVE:
#		velocity = move_and_slide(input_vector * MAXSPEED)
#		var flipped = input_vector.x < 0
#
#		animationPlayer.play("Walking")
##		Server.update_player_position(name, position, sprite.flip_h, "Walking")
	
func update_player(player_position, flip_h):
	sprite.flip_h = flip_h
	if flip_h:
		hitboxCollision.position = Vector2(-12.5,-2)
	else:
		hitboxCollision.position = Vector2(12.5,-2)
	position = player_position
	
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
	var damage = area.damage
	stats.health -= damage
	var attacker = area.get_parent()
	received_knockback(attacker, damage)
	Server.send_player_damage(name, stats.health, global_position, stats.max_health)
	hurtboxCollision.set_deferred("disabled", true)
	hurtBoxDisabledTimer.start()

func received_knockback(attacker: Node, damage: int):
	if receives_knockback:
		var knockback_direction = attacker.position.direction_to(self.global_position)
		var knockback_strength = damage * knockback_multiplier
		var knockback = knockback_direction * knockback_strength
		
		move_and_slide(knockback * 100)


func _on_HurtBoxDisabledTimer_timeout():
	print("hurt done")
	Server.set_player_animation(int(name), "Idle")
	hurtboxCollision.set_deferred("disabled", false)


func _on_Stats_no_health():
	Server.kill_player(str(name))


#func _on_Stats_health_changed():
#	Server.send_player_health(str(name), stats.health, stats.max_health)
