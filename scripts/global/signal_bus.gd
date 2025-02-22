extends Node

signal add_event(resource:EventResource)
signal player_stats(hunger, thirst, moves)
signal effect(hunger, thirst)
signal dice_roll
signal bonus_cards(resource:BonusResource)
signal add_bonus_cards()
signal apply_bonus(resource:BonusResource)
signal remove_bonus(index)
signal current_square(value:int)
signal map_information(size)
signal announcement_set(data)
signal camp
signal show_buttons(value:bool)
signal move_player(dice_roll:int)
signal dice_value(value:int)
signal game_over
signal spawn_dice
signal add_secret_bonuses(resource:BonusResource)
signal open_settings_menu
signal reset
