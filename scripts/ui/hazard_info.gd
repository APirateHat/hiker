extends Control


func _ready() -> void:
	Hazards.update_hazard.connect(update_duration)

func _on_panel_container_mouse_entered() -> void:
	$VBoxContainer.visible = true


func _on_panel_container_mouse_exited() -> void:
	$VBoxContainer.visible = false

func update_duration(num:int):
	print_debug("haz" ,str(num))
	%Label.text = str(num)
