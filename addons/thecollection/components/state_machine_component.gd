extends Node
class_name StateMachineComponent

signal state_changed(last_state: String, new_state: String)

@export var states : Array[String] = ["idle", "run"]

var default_state = states[0]
var current_state = ""
var last_state = ""
var block_states = false

func _ready():
	current_state = states[0]

func change_state(new_state: String) -> void:
	if !new_state in states:
		return
	if block_states:
		return
	last_state = current_state
	current_state = new_state
	state_changed.emit(last_state, current_state)

func force_state(new_state: String, start_signal: Signal):
	block_states = true
	if !new_state in states:
		return
	last_state = current_state
	current_state = new_state
	state_changed.emit(last_state, current_state)
	if start_signal:
		await start_signal
	block_states = false
	change_state(default_state)
	

func get_state():
	return current_state
