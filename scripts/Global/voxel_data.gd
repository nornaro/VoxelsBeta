extends Node

enum voxel_type {AIR, GRASS, SAND, WATER, ICE, STONE, DEBUG, TEST, PINK, PINK2}

# Convert voxel_type to position in our texture_atlas
var tile_map = {
	voxel_type.GRASS: Vector2i(0, 0),
	voxel_type.SAND:  Vector2i(1, 0),
	voxel_type.WATER: Vector2i(2, 0),
	voxel_type.ICE:   Vector2i(3, 0),
	voxel_type.STONE: Vector2i(4, 0),
	voxel_type.DEBUG: Vector2i(5, 0),
	voxel_type.TEST: Vector2i(6, 0),
	voxel_type.PINK: Vector2i(0, 1),
	voxel_type.PINK2: Vector2i(1, 1)
}

## Shorthand for different layout/neighbor configurations depending on map-shape and stagger
const HEXAGONAL_NEIGHBOR_DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, -1),  # Face 0: Top-Right → NE
	Vector2i(1, 0),   # Face 1: Right → E
	Vector2i(0, 1),   # Face 2: Bottom-Right → SE
	Vector2i(-1, 1),  # Face 3: Bottom-Left → SW
	Vector2i(-1, 0),  # Face 4: Left → W
	Vector2i(0, -1)   # Face 5: Top-Left → NW
]

const NEIGHBOR_DIRECTIONS_EVEN: Array[Vector2i] = [ # For even rows (x % 2 == 0) 
	Vector2i(1, -1), # Northeast 
	Vector2i(1, 0), # East 
	Vector2i(0, 1), # Southeast 
	Vector2i(-1, 0), # Southwest 
	Vector2i(-1, -1), # Northwest 
	Vector2i(0, -1) # West 
	] 
	
const NEIGHBOR_DIRECTIONS_ODD: Array[Vector2i] = [ # For odd rows (x % 2 == 1) 
	Vector2i(1, 0), # Northeast 
	Vector2i(1, 1), # East 
	Vector2i(0, 1), # Southeast 
	Vector2i(-1, 1), # Southwest 
	Vector2i(-1, 0), # Northwest 
	Vector2i(0, -1) # West 
	]
	
func get_tile_neighbor_table(row) -> Array[Vector2i]:
	if WorldMap.is_map_staggered:
		if row % 2 == 0:
			return NEIGHBOR_DIRECTIONS_EVEN
		else:
			return NEIGHBOR_DIRECTIONS_ODD
	return HEXAGONAL_NEIGHBOR_DIRECTIONS
