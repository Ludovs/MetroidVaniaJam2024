extends Node2D
class_name CollectableSpawnerComponent

const COLLECTABLE_SPAWN_POINT = preload("res://addons/thecollection/components/collectable_spawn_point.tscn")

@export var collectable: PackedScene
@export var spawn_amount: int = 10
@export var health_component: HealthComponent

func _ready():
	if health_component:
		health_component.died.connect(spawn_collectable)

func spawn_collectable():
	var spawn_point = COLLECTABLE_SPAWN_POINT.instantiate()
	spawn_point.global_position = global_position
	spawn_point.spawn_amount = spawn_amount
	spawn_point.collectable_scene = collectable
	get_tree().current_scene.add_child(spawn_point)
