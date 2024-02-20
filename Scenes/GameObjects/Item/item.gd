extends Node2D

@export var item_sprite : Texture
@export var item_name: String

@onready var sprite = $Sprite
@onready var player = get_tree().get_first_node_in_group("player")
@onready var camera = get_tree().get_first_node_in_group("game_camera")

func _ready():
	if item_sprite:
		sprite.texture = item_sprite

func _process(delta):
	time += delta
	sprite.position.y = get_sine(5, 5)

var time = 0
func get_sine(freq = 1, ampl = 1):
	return sin(time*freq)*ampl


func _on_body_detection_body_detected(body):
	camera.new_target(self, Vector2(2,2))
	player.abilities[item_name] = true
	player.enabled = false
	sprite.visible = false
	$PickupParticles.emitting = true
	$GlowParticles.emitting = false
	await get_tree().create_timer(2.5).timeout
	player.enabled = true
	camera.new_target(player, camera.default_zoom)
	queue_free()
	
