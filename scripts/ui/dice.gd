class_name  Dice
extends Control

var rolling = true
var time : float
var dice_value : int

@export var dice_graphics : Array[Resource]

var dice_audio = [load("res://audio/sfx/dice/dice_roll_1.ogg"),
load("res://audio/sfx/dice/dice_roll_2.ogg"),
load("res://audio/sfx/dice/dice_roll_3.ogg")]

func _ready() -> void:
	SignalBus.dice_value.connect(dice)
	$TextureRect.texture = dice_graphics[0]
	_animation()

func dice(value):
	dice_value = value

func _process(delta: float) -> void:
	if time < 1:
		time += pow(2, 2) * delta
		#$Panel/Label.text = str(randi_range(1, 6))
		$TextureRect.texture = dice_graphics[randi_range(1, 6)-1]
	else:
		#$Panel/Label.text = str(dice_value)
		$TextureRect.texture = dice_graphics[dice_value-1]
		await get_tree().create_timer(1).timeout
		queue_free()

func _animation():
	AudioManager.play_audio(dice_audio.pick_random())
	$TextureRect.pivot_offset = $TextureRect.size/2
	$TextureRect.position = Vector2($TextureRect.position.x, $TextureRect.position.y + 100)
	#$TextureRect.scale = Vector2(0,0)
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($TextureRect, "position", Vector2(0, 0), 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($TextureRect, "scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_property($TextureRect, "scale", Vector2(0.9, 0.9), 0.1).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_property($TextureRect, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(AudioManager.play_audio.bind(dice_audio.pick_random()))

func _exit_tree() -> void:
	pass
	#SignalBus.move_player.emit(dice_value)
