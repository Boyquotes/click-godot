extends Sprite2D

signal clicked

@warning_ignore('unused_parameter')
func _on_static_body_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal('clicked')
