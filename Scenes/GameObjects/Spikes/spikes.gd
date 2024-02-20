extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")

func _on_hitbox_component_body_hit():
	
	player.global_position = Globals.player_respawn_position
