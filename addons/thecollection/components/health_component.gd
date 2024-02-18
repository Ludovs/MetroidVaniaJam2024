extends Node
class_name HealthComponent

signal health_changed(health_amt: float)
signal died
signal damaged
signal shield_protect
signal healed

@export var max_health: float
@export var destroy_on_death: bool = true
@export var immunity_time: float

var curr_health = 0
var is_damaged = false
var is_dead = false

func _ready():
	curr_health = max_health
	health_changed.emit(max_health)
	
func take_damage(attack: Attack):
	if is_damaged:
		return
	if is_dead:
		return
	is_damaged = true
	damaged.emit()
	curr_health -= attack.attack_damage
	health_changed.emit(curr_health)
	if curr_health <= 0:
		died.emit()
		is_dead = true
		if destroy_on_death:
			get_parent().queue_free()
	await get_tree().create_timer(immunity_time).timeout
	is_damaged = false
	
func set_max_health(health_amount: float):
	max_health = health_amount
	curr_health = max_health

func heal(heal_amount):
	curr_health += heal_amount
	if curr_health > max_health:
		curr_health = max_health
	healed.emit()

