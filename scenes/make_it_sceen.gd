@tool
extends EditorScript

#@export_tool_button("Generate") var generate = generate_all

@export var source_dir_base: String = "res://addons/kaykit_medieval_hexagon_pack/Assets/obj"
@export var save_dir_base:   String = "res://assets/kaykit_medieval_hexagon_pack"
@export var albedo_texture:  Texture2D = preload("res://Textures/hexagons_medieval.png")

func _run() -> void:
	_clear_output()
	_process_dir(source_dir_base, save_dir_base)
	print("GENERATE COMPLETE")

func _clear_output() -> void:
	DirAccess.remove_absolute(save_dir_base)
	DirAccess.make_dir_recursive_absolute(save_dir_base)

func _process_dir(src: String, dst: String) -> void:
	var obj_files: Array[String] = []
	for f in DirAccess.get_files_at(src):
		if f.ends_with(".obj"):
			obj_files.append(src.path_join(f))

	var rel := src.trim_prefix(source_dir_base)
	var target := save_dir_base.path_join(rel)
	DirAccess.make_dir_recursive_absolute(target)

	if not obj_files.is_empty():
		_make_items(target, obj_files)

	for sub in DirAccess.get_directories_at(src):
		_process_dir(src.path_join(sub), dst)

func _make_items(dir: String, objs: Array[String]) -> void:
	for obj in objs:
		var mesh := load(obj) as Mesh
		if not mesh:
			continue

		var item_name := obj.get_file().get_basename()
		var tres_path := dir.path_join(item_name + ".tres")
		var tscn_path := dir.path_join(item_name + ".tscn")
		var webp_path := dir.path_join(item_name + ".webp")
		var mesh_path := dir.path_join(item_name + ".mesh")

		# Save .tres
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = albedo_texture
		mesh.surface_set_material(0, mat)
		ResourceSaver.save(mesh, tres_path)

		# Build scene
		var mi := MeshInstance3D.new()
		mi.name = "Mesh"
		mi.mesh = mesh
		mi.rotation.y = deg_to_rad(30)

		var col := CollisionShape3D.new()
		col.name = "Collision"
		col.shape = mesh.create_convex_shape()
		col.rotation.y = deg_to_rad(30)

		var icon := Sprite2D.new()
		icon.name = "Icon"
		
		var body := StaticBody3D.new()
		body.name = item_name
		body.add_child(mi)
		body.add_child(col)
		mi.owner = body
		col.owner = body

		var packed := PackedScene.new()
		packed.pack(body)
		packed.take_over_path(tscn_path)
		ResourceSaver.save(packed, tscn_path)
		ResourceSaver.save(mesh, mesh_path)
		get_editor_interface().make_mesh_previews([mesh], 256)[0].get_image().save_webp(webp_path)


	
