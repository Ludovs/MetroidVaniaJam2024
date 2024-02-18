extends Area2D
class_name HurtboxComponent

signal damaged

@export var health_component: HealthComponent
@export var movement_component: MovementComponent

@onready var player = get_tree().get_first_node_in_group("player")

var attacker_name = ""

func take_damage(attack: Attack, attacker_name_func: String = ""):
	damaged.emit()
	if !health_component:
		return
	health_component.take_damage(attack)
	if !movement_component:
		return
	movement_component.add_velocity(-global_position.direction_to(attack.attack_position)*attack.attack_kb)
	attacker_name = attacker_name_func
	
func _ready():
	if !health_component:
		return
	health_component.died.connect(owner_died)

func owner_died():
	pass
		
