extends Label


onready var timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_error_message(message):
	text = message
	timer.start()


func _on_Timer_timeout():
	text = ""
