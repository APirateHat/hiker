extends Node


@export var sliders : Array[Slider]

func _ready() -> void:
	SignalBus.open_settings_menu.connect(show_settings)
	for slider in sliders:
		slider.value_changed.connect(_set_volume.bind(slider))
		_set_volume(slider.value, slider)

func _set_volume(value:float, slider:Slider):
	Settings.change_volume(value, slider.name)


func _on_button_back_pressed() -> void:
	self.visible = false

func show_settings():
	self.visible = true


func _on_sfx_drag_ended(value_changed: bool) -> void:
	AudioManager.play_audio(load("res://audio/sfx/footstep/footstep-001.ogg"))
