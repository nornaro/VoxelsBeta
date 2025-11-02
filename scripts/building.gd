@tool
extends Unit
class_name Building

func _ready() -> void:
	super()
	unit_name = "Building"
	max_health = 100
	movement_range = 0
	max_height_movement = 0
