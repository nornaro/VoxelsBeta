extends Node
class_name Pathfinder

@export var highlight_marker : PackedScene
var markers = []


func find_reachable_voxels(start: Voxel, unit: Unit) -> Array[Voxel]:
	var queue = []
	var visited = []
	var reachable_voxels: Array[Voxel] = []

	queue.append({"Voxel": start, "distance": 0})
	visited.append(start.grid_position_xz)

	while queue.size() > 0:
		var current = queue.pop_front()
		var current_voxel: Voxel = current["Voxel"]
		var current_distance: int = current["distance"]

		if current_distance > unit.movement_range:
			continue

		reachable_voxels.append(current_voxel)
		var current_pos = current_voxel.grid_position_xyz
		var neighbor_positions = VoxelData.get_tile_neighbor_table(current_pos.x)

		for dir_2d: Vector2i in neighbor_positions:
			var neighbor_2d = current_voxel.grid_position_xz + dir_2d
			if visited.has(neighbor_2d):
				continue

			var neighbor_voxel: Voxel = WorldMap.surface_layer.get(neighbor_2d)
			if not neighbor_voxel:
				continue

			if not is_voxel_valid(neighbor_voxel.grid_position_xyz, current_pos, unit.max_height_movement):
				continue

			queue.append({"Voxel": neighbor_voxel, "distance": current_distance + 1})
			visited.append(neighbor_2d)

	return reachable_voxels


func is_voxel_valid(coords: Vector3i, current_pos: Vector3i, max_height_movement: int) -> bool:
	var voxel: Voxel = WorldMap.map_as_dict.get(coords)
	if voxel:
		var height_diff = abs(voxel.grid_position_xyz.y - current_pos.y)
		if height_diff > max_height_movement:
			return false
		if voxel.occupier == null:
			return true
	return false


func clear_highlight():
	if markers and markers.size() > 0:
		for m in markers:
			m.visible = false


func highlight_voxel(selected_nodes : Array[Voxel]):
	#Ensure correct marker count
	var marker_diff = selected_nodes.size() - markers.size()
	for m in range(marker_diff):
		var new_marker = highlight_marker.instantiate()
		add_child(new_marker)
		markers.append(new_marker)
	clear_highlight() # turn all markers invisible
	# Iterate over selected Voxels
	for i in range(selected_nodes.size()):
		var marker : Node3D = markers[i]
		var voxel : Voxel = selected_nodes[i]
		marker.position = voxel.world_position
		if marker.scale.x != WorldMap.world_settings.voxel_size:
			marker.scale *= WorldMap.world_settings.voxel_size
		marker.position.y += 1
		marker.visible = true
