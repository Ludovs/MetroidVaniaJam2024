extends Area2D
class_name HitboxComponent

signal body_hit

@export var attack_stats: Attack
@export var ignore_hurtbox: HurtboxComponent

func _on_area_entered(area):
	if area is HurtboxComponent:
		if area == ignore_hurtbox:
			return
		attack_stats.attack_position = global_position
		area.take_damage(attack_stats, owner.name)
		body_hit.emit()
