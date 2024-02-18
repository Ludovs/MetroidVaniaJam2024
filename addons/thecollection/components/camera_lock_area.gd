extends Area2D
class_name CameraLockArea

signal body_in
signal body_out

@export var body_group: String
@export var camera_position: Marker2D
@export var camera_zoom: Vector2 = Vector2(1,1)

@onready var camera = get_tree().get_first_node_in_group("game_camera")

func _on_body_entered(body):
	if body.is_in_group(body_group):
		camera.new_target(camera_position, camera_zoom)
		body_in.emit()

func _on_body_exited(body):
	if body.is_in_group(body_group):
		camera.new_target(camera.last_target,Vector2(1,1))
		body_out.emit()
