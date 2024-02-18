extends Node2D

var collectable_scene: PackedScene
var spawn_amount: int

func _ready():
	for i in range(0,spawn_amount):
		var node = collectable_scene.instantiate()
		node.global_position = global_position
		get_tree().current_scene.add_child.call_deferred(node)
		await get_tree().create_timer(0.25).timeout
		SoundManager.play_sound("coin_spawn")
	await get_tree().create_timer(1).timeout
	queue_free()
