extends Control


func transition_to_scene(path:String):
	$CanvasLayer/ColorRect.position = Vector2(0, 648)
	var tween : Tween
	tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($CanvasLayer/ColorRect, "position", Vector2(0,0), 0.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(path))
	tween.tween_callback(transition_out)

func transition_out():
	var tween : Tween
	tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($CanvasLayer/ColorRect, "position", Vector2(0,-648), 0.5)
