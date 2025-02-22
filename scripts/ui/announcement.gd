extends Control


@export var icons = {}
@onready var panel = $PanelContainer
@export var color_plus : Color
@export var color_minus : Color

@export var panel_theme : StyleBoxFlat

func assign_data(icon, value):
	$PanelContainer/MarginContainer/HBoxContainer/TextureRect.texture = icons[icon]
	if value < 0:
		set_color(color_minus)
		$PanelContainer/MarginContainer/HBoxContainer/Label.text = str(value)
	elif value > 0:
		set_color(color_plus)
		$PanelContainer/MarginContainer/HBoxContainer/Label.text = "+"+str(value)
	show_announcement()

func show_announcement():
	panel.pivot_offset = panel.size/2
	panel.scale = Vector2(0,0)
	var tween = get_tree().create_tween()
	tween.tween_property(panel, "scale", Vector2(1.2,1.2), 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(panel, "scale", Vector2(1,1), 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(remove_announcement)
	tween.tween_callback(tween.kill)

func remove_announcement():
	await get_tree().create_timer(2).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(panel, "scale", Vector2(1.2,1.2), 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(panel, "scale", Vector2(0,0), 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(queue_free)

func set_color(color):
	#var theme = StyleBoxFlat.new().duplicate()
	var theme : StyleBox
	theme = panel_theme.duplicate()
	theme.bg_color = color
	$PanelContainer.add_theme_stylebox_override("panel", theme)
