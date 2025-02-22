extends Node

enum state {MENU, STARTED, ENDED, MOVING, READY, DICE_ROLL, EVENT, PAUSED}
var current_state : state :
	get:
		return current_state
	set(game_state):
		current_state = game_state
		states(state_array, game_state)
		match current_state:
			state.MENU:
				print("STATE: MENU")
			state.STARTED:
				print("STATE: STARTED")
			state.ENDED:
				print("STATE: ENDED")
			state.MOVING:
				print("STATE: MOVING")
			state.READY:
				print("STATE: READY")
				MusicManager.eq_music(false)
			state.EVENT:
				MusicManager.eq_music(true)
				print("STATE: EVENT")
			state.PAUSED:
				print("STATE: PAUSED")
		paused()

var previous_state : state
var state_array : Array[state]

func  _ready() -> void:
	states(state_array, current_state)

func states(array:Array, game_state: state) -> void:
	array.append(game_state)
	if array.size() > 2:
		array.remove_at(0)
	previous_state = array[0]
	print("Prev State", previous_state)

func paused():
	if current_state == state.PAUSED:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
