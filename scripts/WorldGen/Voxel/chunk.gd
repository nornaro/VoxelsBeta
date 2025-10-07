extends MeshInstance3D
class_name Chunk

var voxels : Array[Voxel]
var voxel_layers: Dictionary[int, Array] = {}


func init_chunk():
	generate_collider()
	add_to_group("voxels")
	fill_pos_dict()


func generate_collider():
	var body = StaticBody3D.new()
	var col = CollisionShape3D.new()
	var shape = mesh.create_trimesh_shape()
	col.shape = shape
	add_child(body)
	body.add_child(col)


func fill_pos_dict():
	for v: Voxel in voxels:
		var y = v.grid_position_xyz.y
		if not voxel_layers.has(y):
			voxel_layers[y] = []
			print("Voxel layer: ", y)
		voxel_layers[y].append(v)


# We cant just compare against where the user clicked since voxels can have various heights!
# Sort through only the relevant y-level, still slow tho 
func voxel_at_point(point: Vector3) -> Voxel:
	var y = int(floor(point.y))
	var layer = voxel_layers.get(y)
	print("attempted select at: ", y)
	if not layer:
		layer = voxel_layers.get(y-1)
	
	var closest_voxel: Voxel = null
	var min_dist = INF
	for v in layer:
		var dist = v.world_position.distance_to(point)
		if dist < min_dist:
			min_dist = dist
			closest_voxel = v
	return closest_voxel
