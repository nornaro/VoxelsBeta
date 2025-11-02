@tool
class_name Hex
extends Voxel

func _ready() -> void:
	yoffset = 0
	WorldMap.map_pos_dict[position] = self
