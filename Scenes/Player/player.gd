extends CharacterBody2D

@export var abilities = {"Sword": true, "WallJump": true}

@onready var visuals = $Visuals
@onready var animated_sprite = $Visuals/AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var ground_checks = $GroundChecks
@onready var camera = get_tree().get_first_node_in_group("game_camera")
@onready var sword = $Sword
@onready var sword_animation_player = $Sword/AnimationPlayer
@onready var sword_hit_raycast = $Sword/HitRaycast
@onready var right_wall_check = $WallChecks/RightWallCheck
@onready var left_wall_check = $WallChecks/LeftWallCheck
@onready var wall_checks = $WallChecks


#Components ---------------------------------------------------------------------------------------------
@onready var state_machine : StateMachineComponent = $StateMachineComponent

var movement_speed = 110
var movement_accel = 10
var movement_frict = 20

var jump_buffer_frames = 0
var jump_height : float = 42
var jump_time_to_peak : float = 0.25
var jump_time_to_descent : float = 0.35

var wall_jump_velocity = 350
var wall_slide_max_velocity = 25

var is_grounded : bool = false

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _process(delta):
	handle_sprite_flipping()

func _physics_process(delta):
	match state_machine.current_state:
		"idle":
			handle_jump()
			velocity.x = 0
			animation_player.play("idle")
			if abs(get_input_direction()) > 0:
				state_machine.change_state("run")
			if Input.is_action_just_pressed("attack"):
				state_machine.change_state("attack")
		"run":
			handle_movement(delta)
			handle_jump()
			animation_player.play("run")
			if abs(get_input_direction()) == 0:
				state_machine.change_state("idle")
			if Input.is_action_just_pressed("attack"):
				state_machine.change_state("attack")
		"attack":
			if sword_animation_player.is_playing():
				state_machine.change_state("idle")
			handle_movement(delta)
			handle_attack()
			animation_player.play("attack")
			state_machine.change_state("run")
	handle_gravity(delta)
	handle_particles()
	move_and_slide()
	handle_wall_jump()
	handle_wall_sliding()

func handle_attack():
	if !abilities["Sword"]:
		return
	if sword_animation_player.is_playing():
		return
	#sword.scale = visuals.scale
	if int(Input.get_axis("up", "down")) != 0:
		sword.rotation_degrees = 90*int(Input.get_axis("up", "down"))
	elif int(Input.get_axis("up", "down")) == 0:
		if get_input_direction() > 0:
			sword.rotation_degrees = 0
		elif get_input_direction() < 0:
			sword.rotation_degrees = 180
		else:
			sword.rotation_degrees = 0 if visuals.scale.x == 1 else 180
	if sword_hit_raycast.is_colliding():
		ParticleManager.emit_particles("sword_hit_particles", sword_hit_raycast.get_collision_point())
	$Sword/SwordEffect.emitting = true
	velocity.x += 200*(1 if get_input_direction() > 0 else -1)
	camera.do_shake(5,1)
	sword_animation_player.play("swing")

var wall_direction = 1
func handle_wall_jump():
	if !abilities["WallJump"]:
		return
	if right_wall_check.is_colliding():
		wall_direction = 1
	if left_wall_check.is_colliding():
		wall_direction = -1
	
	if Input.is_action_just_pressed("jump"):
		if is_wall_sliding:
			print("walljump")
			velocity.y = -wall_jump_velocity
			velocity.x = (wall_jump_velocity/1.5)*-wall_direction
	
var is_wall_sliding = false
func handle_wall_sliding():
	if !abilities["WallJump"]:
		return
	if get_input_direction() == 0:
		return
	$WallParticles.position.x = 3 if wall_direction == 1 else -3
	if get_is_on_wall():
		if velocity.y > 0:
			if velocity.y > wall_slide_max_velocity:
				velocity.y = wall_slide_max_velocity
				is_wall_sliding = true
				return
	is_wall_sliding = false

func handle_gravity(delta):
	velocity.y += get_gravity()*delta

func handle_jump():
	is_grounded = get_is_grounded()
	if jump_buffer_frames > 0:
		if is_grounded:
			do_jump()
			jump_buffer_frames = 0
		else:
			jump_buffer_frames -= 1
	elif Input.is_action_just_pressed("jump"):
		if is_grounded:
			do_jump()
		else:
			jump_buffer_frames = 20

func handle_movement(delta):
	var movement_input_axis = Input.get_axis("move_left", "move_right")
	movement_input_axis *= movement_speed
	if movement_input_axis != 0:
		velocity.x = lerp(velocity.x, movement_input_axis, 1-exp(-delta*movement_accel))
	else:
		velocity.x = lerp(velocity.x, 0.0, 1-exp(-delta*movement_frict))

var land_count = false
func handle_particles():
	var movement_input_axis = Input.get_axis("move_left", "move_right")
	if abs(movement_input_axis) > 0 && is_grounded:
		$Trail.emitting = true
	else:
		$Trail.emitting = false
	if is_grounded:
		if !land_count:
			if velocity.y > 0:
				ParticleManager.emit_particles("player_jump_land_particles", global_position-Vector2(0,-5))
				camera.do_shake(2.5,1.25)
				land_count = true
	else:
		land_count = false
	
	$WallParticles.emitting = is_wall_sliding

func handle_sprite_flipping():
	if velocity.x == 0:
		return
	if velocity.x > 0:
		visuals.scale = Vector2(1,1)
	if velocity.x < 0:
		visuals.scale = Vector2(-1,1)

func add_velocity(factor : float = 1.5):
	velocity.x*=factor

func get_is_grounded():
	for ray in ground_checks.get_children():
		if ray.is_colliding():
			return true
	return false

func get_is_on_wall():
	for ray in wall_checks.get_children():
		if ray.is_colliding():
			return true
	return false

func get_input_direction():
	return Input.get_axis("move_left", "move_right")

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func do_jump():
	ParticleManager.emit_particles("player_jump_land_particles", global_position-Vector2(0,-5))
	velocity.y = jump_velocity

func do_pogo_jump():
	ParticleManager.emit_particles("player_jump_land_particles", global_position-Vector2(0,-5))
	velocity.y = jump_velocity*1.1

func _on_hitbox_component_body_hit():
	if sword.rotation_degrees == 90:
		do_pogo_jump()

func _on_health_component_damaged():
	camera.do_shake(10,.4)
