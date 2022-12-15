extends Node

var health = 3 setget set_health
var max_health = 3 setget set_max_health

signal no_health
signal health_changed
signal max_health_changed

onready var healthBar = get_node("../PlayerUI/HealthBar")

func set_max_health(value):
	max_health = value
	healthBar.value = (float(health)/max_health) * 100
	health = clamp(health, 0, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = value
	healthBar.value = (float(health)/max_health) * 100
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func _ready():
	self.health = max_health
