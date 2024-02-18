extends Node2D
class_name CollectableComponent

signal collected

@export var movement_component: MovementComponent
@export var collector_group: String
@export var collectable_name: String
@export var collectable_amount: int
@export var collect_particles_name: String
@export var enabled: bool = true

@onready var far_detection = $BodyDetection2
@onready var close_detection = $BodyDetection

func _ready():
	far_detection.body_group = collector_group
	close_detection.body_group = collector_group

func _process(delta):
	if !enabled:
		return
	if far_detection.is_body_in():
		movement_component.accelerate_to_closest_body(collector_group)
	else:
		movement_component.decelerate()
	movement_component.move(get_parent())
	if get_parent() is CharacterBody2D: movement_component.move(get_parent())

func _on_body_detection_body_detected(body):
	if !enabled:
		return
	get_parent().queue_free()
	collected.emit()
