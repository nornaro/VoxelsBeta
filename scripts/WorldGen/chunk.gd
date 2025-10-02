extends MeshInstance3D
class_name Chunk

var voxels : Array[Voxel]
var voxels_grid_dict : Dictionary[Vector3i, Voxel]
var voxels_pos_dict : Dictionary[Vector3, Voxel]

func init_chunk():
		var body = StaticBody3D.new()
		var col = CollisionShape3D.new()
		var shape = mesh.create_trimesh_shape()
		col.shape = shape
		add_child(body)
		body.add_child(col)
		add_to_group("voxels")
		fill_pos_dict()


func fill_pos_dict():
	for v : Voxel in voxels:
		voxels_pos_dict[v.world_position] = v


# Slow process of looking through all voxels
func voxel_at_point(point: Vector3) -> Voxel:
	var closest_voxel: Voxel = null
	var closest_dist := INF

	for pos in voxels_pos_dict.keys():
		var dist = point.distance_squared_to(pos) # squared is cheaper than distance
		if dist < closest_dist:
			closest_dist = dist
			closest_voxel = voxels_pos_dict[pos]

	if closest_voxel == null:
		print("No voxel found near point: ", point, ". Scanned ", voxels_pos_dict.keys().size(), " keys")
	else:
		print("Closest voxel: ", closest_voxel, " at distance: ", sqrt(closest_dist))

	return closest_voxel
