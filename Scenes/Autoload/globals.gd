extends Node

@onready var camera = get_tree().get_first_node_in_group("game_camera")

var player_respawn_position = Vector2(0,0)

func do_camera_shake(sk_amount: float = 5, sk_decay: float = 0.25):
	camera.do_shake(sk_amount, sk_decay)

func do_frame_freeze(time = 0.1):
	Engine.time_scale = 0.1
	await get_tree().create_timer(time*0.01).timeout
	Engine.time_scale = 1
