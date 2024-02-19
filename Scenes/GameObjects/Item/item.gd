extends Node2D

@export var item_sprite : Texture
@export var item_name: String

@onready var sprite = $Sprite

func _ready():
	if item_sprite:
		sprite.texture = item_sprite

func _process(delta):
	time += delta
	sprite.position.y = get_sine(5, 5)

var time = 0
func get_sine(freq = 1, ampl = 1):
	return sin(time*freq)*ampl
