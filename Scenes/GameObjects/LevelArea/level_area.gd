extends Area2D
class_name LevelArea

var player_already_entered = false
var player_in = false

signal player_entered

func player_has_entered():
	if player_already_entered:
		return
	if !player_in:
		return
	player_already_entered = true
	player_entered.emit()


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in = false
