#class_name Bonuses
extends Node2D

#temporary bonuses that last until whatever
enum type {DICE, STAT, MULTIPLIER}

@export var bonus_events : Array[BonusResource]
var applied_bonuses : Array[BonusResource]
var secret_bonus = load("res://resources/bonus_resources/bonus_companion.tres")

func _ready() -> void:
	SignalBus.add_bonus_cards.connect(select_bonuses)
	SignalBus.apply_bonus.connect(applying_bonus)
	
	

func applying_bonus(bonus_data):
	applied_bonuses.append(bonus_data)

func _remove_bonus(bonus_index):
	applied_bonuses.remove_at(bonus_index)
	SignalBus.remove_bonus.emit(bonus_index)

func select_bonuses():
	var array = []
	while array.size() < 2:
		array.append(bonus_events.pick_random())
	SignalBus.bonus_cards.emit(array)
	#return array

func check_for_bonuses(bonus: String):
	if applied_bonuses.size() > 0:
		for i in applied_bonuses:
			if i.id == bonus:
				return true

func get_bonus_effect(bonus: String):
	if applied_bonuses.size() > 0:
		for i in applied_bonuses:
			if i.id == bonus:
				return i.effect

func remove_used_bonus(bonus: String):
	if applied_bonuses.size() > 0:
		for i in applied_bonuses:
			if i.id == bonus:
				print("Removing Used Bonus")
				_remove_bonus(applied_bonuses.find(i))
