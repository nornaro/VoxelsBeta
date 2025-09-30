extends Node

#var map : Array[Voxel]
var map_as_dict : Dictionary[Vector2i, Voxel] = {}
var top_layer_voxels : Array[Voxel]
var is_map_staggered = false
var world_settings : GenerationSettings
var noise_range : Vector2

#var neighbor_positions = HEXAGONAL_NEIGHBOR_DIRECTIONS

## Construct a dictionary for our 2d top layer of voxels
func set_map(voxels):
	map_as_dict.clear()
	for voxel : Voxel in voxels:
		map_as_dict[Vector2i(voxel.grid_position_xz.x, voxel.grid_position_xz.y)] = voxel

func clear_map():
	map_as_dict.clear()
	top_layer_voxels.clear()

## Handy function for finding all neigbors of a tile
#func get_tile_neighbors(tile : Tile) -> Array[Tile]:
	#var neighbors : Array[Tile] = []
	#if is_map_staggered:
		#if tile.pos_data.grid_position.x % 2 == 0:
			#neighbor_positions = NEIGHBOR_DIRECTIONS_EVEN
		#else:
			#neighbor_positions = NEIGHBOR_DIRECTIONS_ODD
			#
	#for direction in neighbor_positions:
		#var neighbor_coords = Vector2(tile.pos_data.grid_position.x + int(direction.x), tile.pos_data.grid_position.y + int(direction.y)) 
		#if neighbor_coords in map_as_dict:
			#neighbors.append(map_as_dict[neighbor_coords])
	#return neighbors
