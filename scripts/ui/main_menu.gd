extends Control


func _ready() -> void:
	StateManager.current_state = StateManager.state.MENU
	MusicManager.play_music(load("res://resources/music/menu_music.tres"), 0.5)

func _on_button_start_pressed() -> void:
	Transition.transition_to_scene("res://scenes/main.tscn")
	MusicManager.fade_out(0.2)


func _on_button_setting_pressed() -> void:
	Settings.open_settings()


func _on_button_pressed() -> void:
	$Credits.visible = false


func _on_button_credits_pressed() -> void:
	$Credits.visible = true
