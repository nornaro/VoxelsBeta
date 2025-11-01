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
			item.name = str(filename.get_basename())
			item.tooltip_text = filepath
			item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			item.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
			#item.ignore_texture_size = true
			
			var label := RichTextLabel.new()
			label.bbcode_enabled = true
			label.scroll_active = false
			label.fit_content = true

			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.size_flags_vertical = Control.SIZE_SHRINK_END
			label.autowrap_mode = TextServer.AUTOWRAP_WORD

			var font := label.get_theme_font("normal_font")
			var font_size := label.get_theme_font_size("normal_font_size")


			label.add_theme_font_override("normal_font", font)
			label.add_theme_font_size_override("normal_font_size", font_size / 1.5)

			label.autowrap_mode = TextServer.AUTOWRAP_WORD
			label.anchor_bottom = 0.0
			label.anchor_left = 0.0
			label.anchor_right = 1.0

			label.text = set_label_name(item.name, instance.name)

			item.add_child(label)
			instance.add_child(item)
			filepath = filepath.replace(".tres",".tscn")
			if !FileAccess.file_exists(filepath):
				print("File missing: ",filepath)
				continue
			var scene:PackedScene = load(filepath)
			item.set_script(button_script)
			Scenelib.lib[item.name] = scene
		%InventoryContainer.add_child(instance)

func set_label_name(txt: String,iname:String) -> String:
	txt = txt.split("_"+iname)[0]
	if txt.contains("building_"):
		return txt.substr(9).replace("_"," ")
	if txt.contains("hex_"):
		return txt.substr(4).replace("_"," ")
	return txt.replace("_"," ")
