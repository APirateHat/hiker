extends Node

#enum state {STARTED, ENDED, MOVING, READY, EVENT}
#var current_state : state

@export var player : Node2D

var first_move = false

@export var squares : Array[Node2D]
var current_square : int
var goal_square : Vector2
var dice_roll : int
var dice_min = 1
var dice_max = 6
var lerp_time = 0

var hazard = false

func _ready() -> void:
	
	MusicManager.play_music(load("res://resources/music/main_music.tres"), 0.5)
	
	for square in $Map.squares.get_children():
		squares.append(square)
	$Camera2D.position = squares[squares.size()-1].global_position
	player.position = squares[0].global_position
	StateManager.current_state = StateManager.state.STARTED
	print(squares.size())
	await get_tree().create_timer(1).timeout
	StateManager.current_state = StateManager.state.READY
	
	SignalBus.dice_roll.connect(roll_dice)
	SignalBus.camp.connect(set_up_camp)
	SignalBus.move_player.connect(move_player)
	SignalBus.reset.connect(reset)
	
	Hazards.start_hazard.connect(hazard_graphics)

func _input(event: InputEvent) -> void:
	pass
	if Input.is_action_just_pressed("ui_down"):
		move_player(1)	


func _process(delta: float) -> void:
	$Camera2D.position = lerp($Camera2D.position, player.position, 0.1)
	if lerp_time <= 1:
		lerp_time += 1 * delta
	player.position = lerp(player.position, squares[current_square].global_position, lerp_time)
	is_player_in_position()
		

func is_player_in_position():
	if StateManager.current_state == StateManager.state.MOVING:
		if player.position == goal_square:
			print("Player On Goal Square")
			player.anim.play("idle", 0.5)
			if check_for_events():
				StateManager.current_state = StateManager.state.EVENT
			else:
				StateManager.current_state = StateManager.state.READY

func check_for_events():
	if squares[current_square].square_type == squares[current_square].type.EVENT:
		squares[current_square].add_event()
		SignalBus.show_buttons.emit(false)
		return true
	elif squares[current_square].square_type == squares[current_square].type.BONUS:
		print("Bonus!")
		SignalBus.add_bonus_cards.emit()
		SignalBus.show_buttons.emit(false)
		return true
	elif squares[current_square].square_type == squares[current_square].type.HAZARD:
		print("HAZARD!")
		Hazards.apply_hazard()
		return false
	else:
		return false

func hazard_check():
	if squares[current_square].square_type == squares[current_square].type.HAZARD:
		return true

func roll_dice():
	player.change_stats(0, 0, -1)
	SignalBus.announcement_set.emit("moves", -1)
	if !first_move:
		first_move = true
	player.set_camp(false)
	var combined_move : int
	if StateManager.current_state == StateManager.state.READY:
		StateManager.current_state = StateManager.state.DICE_ROLL
		if Bonuses.check_for_bonuses("double_dice"):
			var dice_1 = randi_range(1,6)
			var dice_2 = randi_range(1,6)
			combined_move = dice_1 + dice_2
			print("Dice roll 1: ", dice_1)
			print("Dice roll 2: ", dice_2)
			SignalBus.dice_value.emit(dice_1)
			SignalBus.dice_value.emit(dice_2)
			SignalBus.spawn_dice.emit()
			$Camera2D/Control/UI.value_of_dice = combined_move
			Bonuses.remove_used_bonus("double_dice")
		else:
			dice_roll = randi_range(1, 6)
			combined_move = dice_roll
			print("Dice roll: ", dice_roll)
			SignalBus.dice_value.emit(dice_roll)
			SignalBus.spawn_dice.emit()
			$Camera2D/Control/UI.value_of_dice = combined_move
		

func move_player(num:int):
	StateManager.current_state = StateManager.state.MOVING
	var goal = current_square + num
	if current_square < goal:
		while current_square < goal:
			current_square += 1
			SignalBus.current_square.emit(current_square)
			print("current ", current_square)
			lerp_time = 0
			player.play_animation("land_on_tile")
			squares[current_square].anim.play("landed_on")
			squares[current_square].z_index = 2
			squares[current_square-1].z_index = 0
			squares[current_square-1].scale = Vector2(1.0, 1.0)
			if Bonuses.check_for_bonuses("event_stopper"):
				if squares[current_square].square_type == squares[current_square].type.EVENT:
					goal = current_square
					Bonuses.remove_used_bonus("event_stopper")
			if current_square >= squares.size() - 1:
				print("You Finished!")
				$Camera2D/Control/UI.game_finished()
				StateManager.current_state = StateManager.state.ENDED
				break
			if current_square == goal:
				if hazard == true:
					player.change_stats(0, 0, -1)
					SignalBus.announcement_set.emit("moves", -1)
				player.play_animation("land_on_tile")
				print("current square: ", current_square)
				goal_square = squares[current_square].global_position	
				break
			await get_tree().create_timer(0.55, false).timeout
	else:
		while current_square > goal:
			current_square -= 1
			print("current ", current_square)
			lerp_time = 0
			if current_square == goal:
				print("current_square")
				break
			if goal < 0:
				break
			await get_tree().create_timer(0.55).timeout


func set_up_camp():
	if hazard:
		Hazards.update_duration()
	if StateManager.current_state == StateManager.state.READY:
		if player.max_moves - player.moves != 0:
			SignalBus.announcement_set.emit("moves",player.max_moves - player.moves)
		if !Bonuses.check_for_bonuses("slow_metabolism"):
			player.change_stats(-1, -1, player.max_moves - player.moves)
			SignalBus.announcement_set.emit("hunger", -1)
			SignalBus.announcement_set.emit("thirst", -1)
		else:
			player.change_stats(0, 0, player.max_moves - player.moves)
			Bonuses.remove_used_bonus("slow_metabolism")
		if player.food < 0 or player.water < 0:
			print_debug("Game Over")
			SignalBus.game_over.emit()
			StateManager.current_state = StateManager.state.ENDED
	player.set_camp(true)

func hazard_graphics(value:bool):
	if value:
		MusicManager.crossfade_sync_streams(0, 1)
		$Ambience.stream.set_sync_stream_volume(1, -6)
		$Ambience.stream.set_sync_stream_volume(0, -60)
	else:
		$Ambience.stream.set_sync_stream_volume(0, 10.0)
		$Ambience.stream.set_sync_stream_volume(1, -60)
		MusicManager.crossfade_sync_streams(1, 0)
	hazard = value
	$Camera2D/Control/ColorRect.visible = value
	$Camera2D/CPUParticles2D.visible = value
	$Camera2D/CPUParticles2D2.visible = value

func reset():
	MusicManager.eq_music(false)
	$Ambience.stream.set_sync_stream_volume(0, 10.0)
	$Ambience.stream.set_sync_stream_volume(1, -60)
	Bonuses.applied_bonuses.clear()
	Hazards.current_hazard = null
