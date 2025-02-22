extends Node


@export var settings_menu : Node
@export var pause_menu : Node

func change_volume(value:float, slider_name:String):
	var bus_index = AudioServer.get_bus_index(slider_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func open_settings():
	settings_menu.visible = true

func open_pause_menu():
	if !settings_menu.visible:
		pause_menu.visible = !pause_menu.visible
		if pause_menu.visible:
			StateManager.current_state = StateManager.state.PAUSED
		else:
			StateManager.current_state = StateManager.previous_state
	else:
		settings_menu.visible = !settings_menu.visible

func _input(event: InputEvent) -> void:
	if event is InputEvent:
		if event.is_action_pressed("ui_cancel"):
			open_pause_menu()
