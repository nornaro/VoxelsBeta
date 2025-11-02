@tool
extends Node3D
class_name Unit

@export_category("Data")
@export var unit_name : String = "Unit"
@export var max_health: int = 10
var current_health: int = 10
@export var ground_offset : float

@export_category("Movement")
@export var movement_range: int = 3
@export var max_height_movement = 1
@export var model: PackedScene

var occupied_voxel : Voxel
var team # which "team/faction" does this unit belong to


func _ready() -> void:
	current_health = max_health


## Put this unit on a tile at position
func place_unit(voxel: Voxel = null):
	if voxel:
		position = voxel.world_position + Vector3(0,WorldMap.world_settings.voxel_height,0)
	if !voxel:
		if !WorldMap.map_pos_dict.has(position - Vector3.UP):
			return
		voxel = WorldMap.map_pos_dict[position - Vector3.UP]
	leave_tile()
	occupy_tile(voxel)


func occupy_tile(tile : Voxel):
	occupied_voxel = tile
	tile.occupier = self


func leave_tile():
	if occupied_voxel:
		occupied_voxel.occupier = null
