extends Area2D
class_name BodyDetectionComponent

signal body_detected(body)

@export var body_group: String

var body_in = false
var body_node = null

func _on_body_entered(body):
	if body.is_in_group(body_group):
		body_in = true
		body_node = body
		body_detected.emit(body)


func _on_body_exited(body):
	if body.is_in_group(body_group):
		body_in = false
		body_node = null

func is_body_in():
	return body_in
