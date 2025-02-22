extends Node2D

var max_food = 3
var max_water = 3
var max_moves = 3
var food : int
var water : int
var moves : int

@onready var anim = $AnimationPlayer

var footstep_sound = [load("res://audio/sfx/footstep/footstep-001.ogg"),
load("res://audio/sfx/footstep/footstep-002.ogg"),
load("res://audio/sfx/footstep/footstep-003.ogg"),
load("res://audio/sfx/footstep/footstep-004.ogg"),
load("res://audio/sfx/footstep/footstep-005.ogg"),]

var jump_sound = [load("res://audio/sfx/footstep/jump-001.ogg"),
load("res://audio/sfx/footstep/jump-002.ogg"),
load("res://audio/sfx/footstep/jump-003.ogg")]

var camp_sound = [load("res://audio/sfx/camp_1.ogg"),
load("res://audio/sfx/camp_2.ogg"),
load("res://audio/sfx/camp_3.ogg")]

func _ready() -> void:
	food = max_food
	water = max_water
	moves = max_moves
	SignalBus.player_stats.emit(food, water, moves)
	SignalBus.effect.connect(change_stats)

func change_stats(hunger : int, thirst : int, movement: int):
	food += hunger
	water += thirst
	moves += movement
	if moves < 0:
		moves = 0
	SignalBus.player_stats.emit(food, water, moves)

func play_animation(anim:String):
	AudioManager.play_audio(jump_sound.pick_random())
	$AnimationPlayer.play(anim)

func set_camp(value):
	if StateManager.current_state != StateManager.state.ENDED:
		$Camp.visible = value
		$Camp/Campfire/CPUParticles2D.emitting = value
		$Fireplace.playing = value
		if value:
			MusicManager.change_volume(-15)
			AudioManager.play_audio(camp_sound.pick_random())
		else:
			MusicManager.change_volume(0)
	

func play_audio():
	AudioManager.play_audio(footstep_sound.pick_random())
