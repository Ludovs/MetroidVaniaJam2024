extends Node

var particles_folder_path: String = "res://Scenes/Effects/"

func emit_particles(particles_name: String, emit_position: Vector2, particle_color: Color = Color.BLACK):
	var particle_node = load(particles_folder_path+particles_name+".tscn").instantiate()
	particle_node.global_position = emit_position
	if particle_color != Color.BLACK:
		particle_node.color = particle_color
	get_tree().get_first_node_in_group("main").add_child.call_deferred(particle_node)
	
