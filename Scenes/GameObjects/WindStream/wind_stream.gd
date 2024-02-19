extends Node2D

@export var wind_stenght = 35

@onready var body_detection = $BodyDetection

func _process(delta):
	if body_detection.body_in:
		if body_detection.body_node is Player:
			if body_detection.body_node.is_gliding:
				body_detection.body_node.velocity.y -= wind_stenght
