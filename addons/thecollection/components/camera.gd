extends Camera2D
class_name GameCamera

@export var target_node: Node2D
@export var camera_enabled: bool = true

var shake_amount = 0
var shake_decay = 0

func _ready():
	add_to_group("game_camera")

func _physics_process(delta):
	if !camera_enabled:
		return
	if shake_amount > 0:
		shake_amount -= shake_decay
	if shake_amount < 0:
		shake_amount = 0
	
	offset = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
	
	if !target_node:
		return
	global_position = target_node.global_position
func do_shake(shake_value, sk_decay = 0.25):
	shake_amount += shake_value
	shake_decay = sk_decay

var last_target
func new_target(node, cam_zoom: Vector2):
	if !node:
		return
	last_target = target_node
	target_node = node
	zoom = cam_zoom


func _on_level_detector_area_entered(area):
	get_tree().paused = true
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	if area is LevelArea:
		area.player_has_entered()
		var collision_shape = area.get_node("CollisionShape2D")
		var size = collision_shape.shape.extents*2
		
		var view_size = get_viewport_rect().size
		if size.y < view_size.y:
			size.y = view_size.y
			
		if size.x < view_size.x:
			size.x = view_size.x
		
		limit_top = collision_shape.global_position.y - size.y/2
		limit_left = collision_shape.global_position.x - size.x/2
		
		limit_bottom = limit_top + size.y
		limit_right = limit_left + size.x
