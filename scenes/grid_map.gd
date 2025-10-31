@tool
extends GridMap

@export_tool_button("Clear") var c = _ready

func _ready() -> void:
	self.clear()
