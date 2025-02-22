extends Control


func assign_data(data:BonusResource):
	$TextureRect.texture = data.icon
	$PanelContainer/MarginContainer/Label.text = data.description


func _on_mouse_entered() -> void:
	$PanelContainer.visible = true
	print("Hovering")


func _on_mouse_exited() -> void:
	$PanelContainer.visible = false
