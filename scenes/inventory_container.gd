extends TabContainer

var base_path:String = "res://assets/kaykit_medieval_hexagon_pack/"
@onready var button_script:Script = preload("res://scripts/hex_buildable.gd")

func _ready() -> void:
	get_folder_dict()
		
func get_folder_dict(path:String = "res://assets/kaykit_medieval_hexagon_pack/") -> void:
	var result:Dictionary = {}
	
	for subdir in DirAccess.get_directories_at(path):
		var subpath := path.path_join(subdir)
		for groupname in DirAccess.get_directories_at(subpath):
			var full_path := subpath.path_join(groupname)
			result[groupname] = full_path
			print("FP: ",full_path)
	
	for key in result.keys():
		var instance := GridContainer.new()
		instance.name = key
		instance.columns = floori(%InventoryContainer.size.x / 100)
		
		for filename in DirAccess.get_files_at(result[key]):
			var filepath :String = result[key] + "/" + filename
			
			if !filename.ends_with(".tres"):
				continue
			if !FileAccess.file_exists(filepath):
				continue
			var mesh:Mesh = load(filepath)
			if mesh == null:
				continue
			
			var mesh_node := MeshInstance3D.new()
			mesh_node.mesh = mesh
			
			var temp_scene := PackedScene.new()
			temp_scene.pack(mesh_node)
			
			var tex :SceneTexture = SceneTexture.new()
			tex.camera_distance *= 3
			tex.scene = temp_scene
			var item := TextureButton.new()
			item.texture_normal = tex
			item.name = filename.get_basename()
			item.tooltip_text = filepath
			instance.add_child(item)
			filepath = filepath.replace(".tres",".tscn")
			if !FileAccess.file_exists(filepath):
				print("File missing: ",filepath)
				continue
			var scene:PackedScene = load(filepath)
			item.set_script(button_script)
			Scenelib.lib[item.name] = scene
		%InventoryContainer.add_child(instance)
