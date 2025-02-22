extends Node


func _on_button_continue_pressed() -> void:
	self.visible = false
	StateManager.current_state = StateManager.previous_state


func _on_button_exit_pressed() -> void:
	SignalBus.reset.emit()
	Transition.transition_to_scene("res://scenes/main_menu.tscn")
	self.visible = false
	StateManager.current_state = StateManager.previous_state


func _on_button_settings_pressed() -> void:
	SignalBus.open_settings_menu.emit()


func _on_button_restart_pressed() -> void:
	SignalBus.reset.emit()
	Transition.transition_to_scene("res://scenes/main.tscn")
	StateManager.current_state = StateManager.previous_state
	self.visible = false
