extends StaticBody3D

func _ready() -> void:
	
	print(position.y)
	pass # Replace with function body.

func _on_property_list_changed() -> void:
	print(position.y)
	pass # Replace with function body.


func _on_visibility_changed() -> void:
	print(position.y)
	pass # Replace with function body.


func _on_input_event(_camera: Node, _event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	print(position.y)
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	print(position.y)
	pass # Replace with function body.
