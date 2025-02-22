extends Node2D

@export var resource : Resource

enum type {EMPTY, EVENT, BONUS, HAZARD}
var square_type: type
@onready var anim = $AnimationPlayer
@onready var icon = $Icon


func add_event():
	if resource != null:
		#await get_tree().create_timer(0.5).timeout
		SignalBus.add_event.emit(resource)
