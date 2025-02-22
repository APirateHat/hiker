extends Node2D

@export var hazards : Array[HazardResource]
var current_hazard : HazardResource

signal update_hazard(num:int)
signal start_hazard(value:bool)
#signal end_hazard

func apply_hazard():
	current_hazard = hazards[0]
	start_hazard.emit(true)

func update_duration():
	current_hazard.duration -= 1
	print("Hazard Duration" , current_hazard.duration)
	update_hazard.emit(current_hazard.duration)
	if current_hazard.duration <= 0:
		current_hazard = null
		start_hazard.emit(false)
