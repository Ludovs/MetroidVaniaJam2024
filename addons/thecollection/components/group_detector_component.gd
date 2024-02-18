extends Area2D
class_name GroupDetectorComponent

signal bodies_in
signal no_bodies

@export var detector_group: String

func check() -> bool:
	for body in get_overlapping_bodies():
		if body.is_in_group(detector_group):
			return true
	return false
