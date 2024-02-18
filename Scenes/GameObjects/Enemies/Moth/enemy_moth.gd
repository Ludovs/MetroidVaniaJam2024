extends CharacterBody2D

@onready var movement_component = $MovementComponent
@onready var visuals = $Visuals
@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("fly")

func _process(delta):
	movement_component.accelerate_to_closest_body("player")
	movement_component.move(self)
	if velocity.x > 0:
		visuals.scale.x = 1
	if velocity.x < 0:
		visuals.scale.x = -1

func _on_health_component_damaged():
	ParticleManager.emit_particles("blood_particles", global_position)
	


func _on_health_component_died():
	ParticleManager.emit_particles("blood_particles", global_position)
	ParticleManager.emit_particles("blood_particles", global_position)
	queue_free()


func _on_hitbox_component_body_hit():
	movement_component.add_velocity(Vector2.UP*250)
