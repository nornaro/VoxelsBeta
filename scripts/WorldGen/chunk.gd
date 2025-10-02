extends MeshInstance3D
class_name Chunk

var voxels : Array[Voxel]
var voxels_dict : Dictionary[Vector3i, Voxel]

func init_chunk():
		var body = StaticBody3D.new()
		var col = CollisionShape3D.new()
		var shape = mesh.create_trimesh_shape()
		col.shape = shape
		
		add_child(body)
		body.add_child(col)
		add_to_group("voxels")
