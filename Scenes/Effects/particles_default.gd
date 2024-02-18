extends CPUParticles2D

func _ready():
	emitting = true
	one_shot = true
	await get_tree().create_timer(lifetime).timeout
	queue_free()
