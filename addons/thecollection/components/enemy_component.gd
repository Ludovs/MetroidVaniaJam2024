extends Node2D
class_name EnemyComponent

signal enemy_in_range

@export var character_body: CharacterBody2D
@export var follow_node_group: String = "player"
@export var follow_node: bool = true
@export var movement_component: MovementComponent

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	character_body.add_to_group("enemy")
	
func _physics_process(delta):
	var move_direction = character_body.global_position.direction_to(player.global_position)
	movement_component.move(character_body)
	if follow_node:
		movement_component.accelerate_in_direction(move_direction)
	else:
		movement_component.decelerate()

