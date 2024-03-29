extends CharacterBody2D
class_name Player

@export var abilities = {"Sword": true, "WallJump": true, "Dash": true, "Gliding": true}

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
@onready var glider = $Glider


#Components ---------------------------------------------------------------------------------------------
@onready var state_machine : StateMachineComponent = $StateMachineComponent

var movement_speed = 100
var movement_accel = 10
var movement_frict = 20

var jump_buffer_frames = 0
var jump_height : float = 42
var jump_time_to_peak : float = 0.25
var jump_time_to_descent : float = 0.35

var wall_jump_velocity = 350
var wall_slide_max_velocity = 25

var dash_velocity = 250
var dashing_time = 0.25

var gliding_max_velocity = 25
var gliding_power = 100
var gliding_decay = .5

var is_grounded : bool = false
var is_dashing = false
var is_gliding = false

var can_dash = true

var facing_direction = 1 #1 if right, -1 if left
var enabled = true

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _process(delta):
	handle_sprite_flipping()

func _physics_process(delta):
	handle_gravity(delta)
	move_and_slide()
	if !enabled:
		velocity.x = 0
		animation_player.play("idle")
		return
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
	
	handle_particles()
	handle_wall_jump()
	handle_wall_sliding()
	handle_dash()
	handle_gliding()

func handle_gliding():
	var tween = create_tween()
	if !abilities["Gliding"]:
		tween.tween_property(glider, "scale", Vector2(0,0), 0.05)
		return
	if !is_gliding or gliding_power <= 0:
		tween.tween_property(glider, "scale", Vector2(0,0), 0.25)

	if is_grounded:
		gliding_power = 100
		is_gliding = false
		return
	glider.get_node("AnimationPlayer").play("glide")
	is_gliding = Input.is_action_pressed("glide")
	if is_gliding && gliding_power > 0 && !is_grounded:
		gliding_power -= gliding_decay if gliding_decay > 0 else 0
		tween.tween_property(glider, "scale", Vector2(1,1), 0.05)
		if velocity.y > gliding_max_velocity:
			velocity.y = gliding_max_velocity
func handle_dash():
	if !abilities["Dash"]:
		return
	if is_grounded or is_wall_sliding:
		can_dash = true
	if is_dashing:
		velocity.x = dash_velocity*get_input_direction()
		velocity.y = 0 if Input.get_axis("up", "down") > -1 else -dash_velocity/4
	if !can_dash:
		return
	if get_input_direction() == 0 && Input.get_axis("up", "down") == 0:
		return
	if Input.is_action_just_pressed("dash"):
		is_dashing = true
		can_dash = false
		await get_tree().create_timer(dashing_time).timeout
		is_dashing = false
	

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
	if facing_direction > 0 && Input.get_axis("up", "down") == 0:
		velocity.x += 200
	if facing_direction < 0 && Input.get_axis("up", "down") == 0:
		velocity.x -= 200
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
			ParticleManager.emit_particles("player_jump_land_particles", global_position-Vector2(0,-5))
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
	$Visuals/DashingParticles.emitting = is_dashing
	
func handle_sprite_flipping():
	if velocity.x == 0:
		return
	if velocity.x > 0:
		facing_direction = 1
		visuals.scale = Vector2(1,1)
	if velocity.x < 0:
		facing_direction = -1
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
	Globals.do_frame_freeze()
