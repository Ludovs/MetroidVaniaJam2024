extends Area2D
class_name InteractionAreaComponent

signal interaction

@export var body_group: String
var body_in = false

func _process(delta):
	if Input.is_action_just_pressed("interaction"):
		if body_in:
			interaction.emit()

func _on_body_entered(body):
	if body.is_in_group(body_group):
		body_in = true

func _on_body_exited(body):
	if body.is_in_group(body_group):
		body_in = false
