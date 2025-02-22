class_name EventResource
extends Resource

var event_type = "Event"

@export var id: String
@export_multiline var description : String
@export var choice : bool
@export var decision : bool
@export var choice_yes : String
@export var choice_no : String
@export var effect = {
	"good":{
		"hunger": 0,
		"thirst": 0,
		"moves": 0},
	"bad":{
		"hunger": 0,
		"thirst": 0,
		"moves": 0}	
		}

@export var decision_effect = {
	"hunger": 0,
	"thirst": 0,
	"moves": 0}
	
@export_range(0, 10) var risk : int
