class_name BonusCard
extends Control

@export var card_name : Label
@export var card_description : Label
@export var card_icon : TextureRect
var card_data : BonusResource
@export var button: Button

signal card_toggled(toggle: bool)
signal card_selected(data)

func _on_button_toggled(toggled_on: bool) -> void:
	card_toggled.emit(toggled_on)


func _on_button_pressed() -> void:
	card_selected.emit(card_data)

func assign_data(data: BonusResource) -> void:
	card_data = data
	card_name.text = data.bonus_name
	card_description.text = data.description
	card_icon.texture = data.icon


func _on_button_mouse_entered() -> void:
	self.pivot_offset = self.size/2
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.1)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)


func _on_button_mouse_exited() -> void:
	self.pivot_offset = self.size/2
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
