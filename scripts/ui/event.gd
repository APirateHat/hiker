extends Control


@export var description : Label
var choice : bool
@export var choice_buttons : Control
@export var button_okay : Button

@export var icons = {}
@export var icon_parent : Control

var data : EventResource

var stamp_audio = [load("res://audio/sfx/event/stamp_1.ogg"), load("res://audio/sfx/event/stamp_2.ogg"),
load("res://audio/sfx/event/stamp_3.ogg")]

func _ready():
	for i in icons:
		get_node(icons[i]).mouse_entered.connect(_on_mouse_enter_icon)
		get_node(icons[i]).mouse_exited.connect(_on_mouse_exit_icon)

func assign_data(event_data):
	data = event_data
	description.text = data.description
	if data.choice:
		button_okay.visible = false
		choice_buttons.visible = true
		choice_buttons.get_child(0).text = data.choice_yes
		choice_buttons.get_child(1).text = data.choice_no
	for i in data.effect.good:
		if data.effect.good[i] > 0 or data.effect.good[i] < 0:
			get_node(icons[i]).visible = true
	for i in data.effect.bad:
		if data.effect.bad[i] < 0:
			get_node(icons[i]).visible = true
	for i in data.decision_effect:
		if data.decision_effect[i] > 0 or data.decision_effect[i] < 0:
			get_node(icons[i]).visible = true
				

func _on_button_okay_pressed() -> void:
	for i in data.effect.good:
		if data.effect.good[i] > 0:
			SignalBus.announcement_set.emit(i, data.effect.good[i])
	SignalBus.effect.emit(data.effect.good.hunger, data.effect.good.thirst, data.effect.good.moves)
	queue_free()

func _on_button_no_pressed() -> void:
	for i in data.decision_effect:
		if data.decision_effect[i] > 0 or data.decision_effect[i] < 0:
			SignalBus.announcement_set.emit(i, data.decision_effect[i])
	if data.decision:
		SignalBus.effect.emit(data.decision_effect.hunger, data.decision_effect.thirst, data.decision_effect.moves)
	queue_free()

func _on_button_yes_pressed() -> void:
	if data.risk == 0:
		set_data(true)
	else:
		get_chance()

func get_chance():
	var rand_num = randi_range(1, 10)
	if Bonuses.check_for_bonuses("lucky_clover"):
		rand_num = 10
		Bonuses.remove_used_bonus("lucky_clover")
	print_debug("Success rate: ", rand_num)
	if rand_num > data.risk:
		$Stamp/AnimationPlayer.play("stamp_pass")
	else:
		$Stamp/AnimationPlayer.play("stamp_fail")
		$Stamp/TextureRect.texture = load("res://graphics/stamps/fail.svg")


func set_data(passed:bool):
	if passed:
		if data.id == "wolf":
			Bonuses.applying_bonus(Bonuses.secret_bonus)
			SignalBus.add_secret_bonuses.emit(Bonuses.secret_bonus)
		for i in data.effect.good:
			if data.effect.good[i] > 0 or data.effect.good[i] < 0:
				if Bonuses.check_for_bonuses("double_resource"):
					print_debug("Double Resource!")
					SignalBus.announcement_set.emit(i, data.effect.good[i] * Bonuses.get_bonus_effect("double_resource"))
					Bonuses.remove_used_bonus("double_resource")
				else:
					SignalBus.announcement_set.emit(i, data.effect.good[i])
		SignalBus.effect.emit(data.effect.good.hunger, data.effect.good.thirst, data.effect.good.moves)
	else:
		print_debug("Fail")
		for i in data.effect.bad:
			if data.effect.bad[i] < 0:
				if Bonuses.check_for_bonuses("resource_saved"):
					Bonuses.remove_used_bonus("resource_saved")
					print("Saved Resource!")
					
				else:
					SignalBus.announcement_set.emit(i, data.effect.bad[i])
					SignalBus.effect.emit(data.effect.bad.hunger, data.effect.bad.thirst, data.effect.bad.moves)
	free_event()

func play_audio():
	AudioManager.play_audio(stamp_audio.pick_random(), 10.0)

func free_event():
	queue_free()

func _on_mouse_enter_icon():
	$Tooltip.visible = true

func _on_mouse_exit_icon():
	$Tooltip.visible = false

func _exit_tree() -> void:
	print_debug("Event resolved")
	SignalBus.show_buttons.emit(true)
	StateManager.current_state = StateManager.state.READY
