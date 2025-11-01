@tool
extends Node3D

@export_tool_button("Generate") var generate = generate_from_obj
@export_tool_button("Texture") var texture = texture_res
@export_tool_button("MeshUp") var mup = mesh_up
@export var source_dir_base:String = "res://addons/kaykit_medieval_hexagon_pack/Assets/obj"
@export var save_dir_base:String = "res://assets/kaykit_medieval_hexagon_pack"
@export var albedo_texture = preload("res://Textures/hexagons_medieval.png")

func generate_from_obj() -> void:
	_process_dir(source_dir_base,save_dir_base)
	return
	
func mesh_up():
	mesh_update()
	
func mesh_update(save_dir:String = "res://assets/kaykit_medieval_hexagon_pack") -> void:
	var dirs = DirAccess.get_directories_at(save_dir)
	var files = DirAccess.get_files_at(save_dir)

	for f in files:
		if f.ends_with(".tscn"):
			replace_mesh_with_tres(save_dir+f)
	print(files)

	for d in dirs:
		mesh_update(save_dir + "/" + d)
	

func _process_dir(source_dir:String, save_dir:String) -> void:
	var dirs = DirAccess.get_directories_at(source_dir)
	var files = DirAccess.get_files_at(source_dir)
	var obj_files:Array[String] = []

	for f in files:
		if !f.ends_with(".obj"):
			continue
		obj_files.append(source_dir + "/" + f)

	var rel_path = source_dir.trim_prefix(source_dir_base)
	var target_dir = save_dir_base.path_join(rel_path)

	if !obj_files.is_empty():
		_generate_scene_from_objs(target_dir, obj_files)

	for d in dirs:
		_process_dir(source_dir + "/" + d, save_dir)




func _generate_scene_from_objs(path:String, obj_files:Array[String]) -> void:
	var folder_name = path.get_file()
	var root = Node3D.new()
	root.name = folder_name

	for obj_path in obj_files:
		var mesh:Mesh = ResourceLoader.load(obj_path)
		if mesh == null:
			continue

		# use filename instead of mesh name
		var mesh_name = obj_path.get_file().get_basename()
		var mesh_res_path = path + "/" + mesh_name + ".tres"
		DirAccess.make_dir_recursive_absolute(path)
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = albedo_texture
		mesh.surface_set_material(0,mat)
		
		ResourceSaver.save(mesh, mesh_res_path)

		var mesh_node = MeshInstance3D.new()
		mesh_node.mesh = mesh
		mesh_node.name = mesh_name
		mesh_node.rotation.y = deg_to_rad(30)

		var body = StaticBody3D.new()
		body.name = mesh_name
		
		root.add_child(body)
		body.add_child(mesh_node)
		
		_add_convex_collisions(body, mesh_node.mesh, root)
		
		body.owner = root
		mesh_node.owner = root
		
		_save_child_scene(path, body)

	#var packed = PackedScene.new()
	#packed.pack(root)
	#ResourceSaver.save(packed, path + "/" + folder_name + ".tscn")



func _add_convex_collisions(body:StaticBody3D, mesh:Mesh, root:Node) -> void:
	var count = mesh.get_surface_count()
	for i in count:
		var shape = mesh.create_convex_shape(i)
		if shape == null:
			continue
		var collision = CollisionShape3D.new()
		collision.shape = shape
		collision.rotation.y = deg_to_rad(30)
		collision.name = "Collision" + str(i)
		body.add_child(collision)
		collision.owner = root


func _save_child_scene(path:String, node:Node) -> void:
	#DirAccess.make_dir_recursive_absolute(path)
	var temp = node.duplicate()
	_set_ownership_recursive(temp, temp) # temporarily set ownership to temp’s children
	temp.owner = null # prevent self-ownership before packing
	var packed = PackedScene.new()
	packed.pack(temp)
	ResourceSaver.save(packed, path + "/" + node.name + ".tscn")
	temp.free()

func _set_ownership_recursive(node:Node, o:Node) -> void:
	for c in node.get_children():
		c.owner = o
		_set_ownership_recursive(c, o)

func texture_res(path: String = "res://assets/kaykit_medieval_hexagon_pack/") -> void:
	# Process all .res files in this folder
	for file in DirAccess.get_files_at(path):
		if !file.ends_with(".res"):
			continue
		var res_path = path  + "/" + file
		var mat:ArrayMesh = ResourceLoader.load(res_path)
		for s in mat.get_surface_count():
			mat.surface_get_material(s).albedo_texture = albedo_texture
			print("Updated albedo for:", res_path)
		ResourceSaver.save(mat,res_path)


	# Recurse into subdirectories
	for dir in DirAccess.get_directories_at(path):
		texture_res(path + "/" + dir)


func replace_mesh_with_tres(scene_path:String) -> void:
	var scene = ResourceLoader.load(scene_path).instantiate()
	print(scene)
	for child in scene.get_children():
		if child is MeshInstance3D:
			child.mesh = load(scene_path.get_basename() + ".tres")
	var packed_new = PackedScene.new()
	packed_new.pack(scene)
	ResourceSaver.save(packed_new, scene_path)
	print("Updated meshes to .tres in:", scene_path)
	scene.free()
