extends Path2D

@export_range(0.1,4) var move_speed_scale = 1.0
@export var moving: bool = true

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("move")
	animation_player.speed_scale = move_speed_scale
	
