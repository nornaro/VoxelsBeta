extends Button

func _ready() -> void:
	connect("pressed",_on_pressed)

func _on_pressed() -> void:
	%Minimap.position.y -= 16
