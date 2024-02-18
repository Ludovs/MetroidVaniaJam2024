extends Node
class_name MovementComponent

@export var max_speed : int = 40
@export var acceleration : float = 5
@export var enabled : bool = true

var velocity = Vector2.ZERO

func accelerate_to_closest_body(body_group: String, MAX_RANGE = 150):
	var bodies = get_tree().get_nodes_in_group(body_group)
	bodies = bodies.filter(func(body : Node2D): return body.global_position.distance_squared_to(owner.global_position) < pow(MAX_RANGE, 2))
	if bodies.size() == 0:
		decelerate()
		return
	
	bodies.sort_custom(func(a:Node2D, b:Node2D):
		var a_distance = a.global_position.distance_squared_to(owner.global_position)
		var b_distance = b.global_position.distance_squared_to(owner.global_position)
		return a_distance < b_distance
	)
	
	var move_direction = owner.global_position.direction_to(bodies.front().global_position)
	accelerate_in_direction(move_direction)

func accelerate_in_direction(direction: Vector2):
	var desired_velocity = direction*max_speed
	velocity = velocity.lerp(desired_velocity, 1-exp(-acceleration*get_process_delta_time()))

func decelerate():
	accelerate_in_direction(Vector2.ZERO)

func still():
	velocity = Vector2(0,0)

func add_velocity(vel):
	velocity += vel

func move(character_body: CharacterBody2D):
	character_body.velocity = velocity
	character_body.move_and_slide()
	velocity = character_body.velocity
