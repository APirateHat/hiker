class_name BonusResource
extends Resource

var event_type = "Bonus"
@export var bonus_name : String
@export_multiline var description : String
@export var icon : Texture2D

enum type {DICE, STAT, MULTIPLIER}
@export var bonus_type : type

@export var effect : int
@export var id : String
