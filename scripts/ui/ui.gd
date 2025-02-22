extends Control

@export var event : PackedScene
@export var event_parent : Control

@export var bonus_card : PackedScene
@export var bonus_card_parent : Control
@export var bonus_icon : PackedScene
var bonus_icons_collection : Array
@export var bonus_icon_parent : Control
var cards : Array

@export var announcement : PackedScene
@export var announcement_parent : Control

@export var dice : PackedScene
var value_of_dice : int

@onready var player_stats = {
	"hunger" = %HungerStat,
	"thirst" = %ThirstStat,
	"moves" = %MovesStat
}

var player_hunger : int
var player_thirst : int
var player_moves : int

@export var timeline_sliders : Array[Slider]

@export var button_dice: Button
@export var button_camp: Button

var dice_created = false

@export var pause_menu : Node
#@export var settings_menu : Node

func _ready() -> void:
	$BonusUI.visible = false
	SignalBus.add_event.connect(add_event)
	SignalBus.player_stats.connect(display_player_stats)
	SignalBus.bonus_cards.connect(setup_bonus_cards)
	SignalBus.current_square.connect(display_steps)
	SignalBus.map_information.connect(map_information)
	SignalBus.remove_bonus.connect(remove_bonus_icon)
	SignalBus.announcement_set.connect(add_announcement)
	SignalBus.show_buttons.connect(show_buttons)
	#SignalBus.dice_value.connect(create_dice)
	SignalBus.dice_value.connect(add_to_dice_array)
	SignalBus.spawn_dice.connect(create_dice)
	SignalBus.game_over.connect(game_over)
	SignalBus.add_secret_bonuses.connect(add_bonus_icon)
	
	Hazards.start_hazard.connect(hazard_info)
	
	for i in Bonuses.applied_bonuses:
		add_bonus_icon(i)
	

#func _input(event: InputEvent) -> void:
	#if event is InputEvent:
		#if event.is_action_pressed("ui_cancel"):
			#open_pause_menu()

func add_event(resource):
	var e = event.instantiate()
	event_parent.add_child(e)
	if resource != null:
		e.assign_data(resource)	

func display_player_stats(food, water, moves):
	player_stats.hunger.text = str(food)
	player_stats.thirst.text = str(water)
	player_stats.moves.text = str(moves)
	
	#player_moves = moves
	#player_thirst = water
	#player_hunger = food
	
	if moves == 10:
		button_camp.disabled = true
		button_dice.disabled = false
	elif moves == 0:
		button_dice.disabled = true
	else:
		button_camp.disabled = false
		button_dice.disabled = false

func _on_button_dice_roll_pressed() -> void:
	SignalBus.dice_roll.emit()

func add_bonus_card(data:BonusResource):
	var bc : BonusCard = bonus_card.instantiate()
	cards.append(bc)
	bonus_card_parent.add_child(bc)
	bc.assign_data(data)
	bc.card_selected.connect(bonus_selected.bind(bc.get_index()))

func bonus_selected(data, index: int):
	for card in cards:
		if card.get_index() != index:
			card.queue_free()
			cards.remove_at(card.get_index())

	SignalBus.apply_bonus.emit(cards[0].card_data)
	add_bonus_icon(cards[0].card_data)	
	$BonusUI.visible = false
	SignalBus.show_buttons.emit(true)
	StateManager.current_state = StateManager.state.READY
	for card in cards:
		card.queue_free()
	cards.clear()
	AudioManager.play_audio(load("res://audio/sfx/cards/pick_cards-002.ogg"))

func add_bonus_icon(data):
	var bi = bonus_icon.instantiate()
	bi.assign_data(data)
	bonus_icon_parent.add_child(bi)
	bonus_icons_collection.append(bi)

func remove_bonus_icon(index):
	bonus_icons_collection[index].queue_free()
	bonus_icons_collection.remove_at(index)

func setup_bonus_cards(data):
	AudioManager.play_audio(load("res://audio/sfx/cards/card_event_3.ogg"))
	$BonusUI.visible = true
	add_bonus_card(data[0])
	add_bonus_card(data[1])

func display_steps(value:int):
	timeline_sliders[0].value = value

func map_information(size):
	for i in timeline_sliders:
		i.max_value = size
	timeline_sliders[1].value = size

var announcement_queue : Array

func add_announcement(icon, value):
	#print("Adding announcement")
	var a = announcement.instantiate()
	announcement_parent.add_child(a)
	a.assign_data(icon, value)

func _on_button_camp_pressed() -> void:
	SignalBus.camp.emit()

func show_buttons(value:bool):
	$Buttons.visible = value


var dice_value_array : Array
func add_to_dice_array(value):
	dice_value_array.append(value)

func create_dice():
	for i in dice_value_array:
		dice_created = true
		var d :Dice = dice.instantiate()
		d.dice_value = i
		$DiceUI/HBoxContainer.add_child(d)

func game_over():
	$GameOver.visible = true

func game_finished():
	await get_tree().create_timer(0.5).timeout
	$GameFinished.visible = true

var dice_values : Array

func _process(delta: float) -> void:
	if dice_created == true:
		if $DiceUI/HBoxContainer.get_child_count() == 0:
			print("Dice Gone")
			dice_value_array.clear()
			SignalBus.move_player.emit(value_of_dice)
			dice_created = false

func restart_game():
	SignalBus.reset.emit()
	Transition.transition_to_scene("res://scenes/main.tscn")

func go_to_main_menu():
	SignalBus.reset.emit()
	Transition.transition_to_scene("res://scenes/main_menu.tscn")


func _on_button_pressed() -> void:
	SignalBus.reset.emit()
	restart_game()


func _on_button_2_pressed() -> void:
	SignalBus.reset.emit()
	go_to_main_menu()

func hazard_info(value:bool):
	$VBoxContainer/HazardInfo.visible = value


func _on_button_open_pause_pressed() -> void:
	Settings.open_pause_menu()
