extends GridContainer

var base_path:String = "res://assets/kaykit_medieval_hexagon_pack/"

func _ready() -> void:
	get_folder_tree()
	print(DirAccess.get_directories_at(base_path))
	#for dir in DirAccess.get_directories_at(path):
		#p
		
func get_folder_tree(path:String = "res://assets/kaykit_medieval_hexagon_pack/") -> Dictionary:
	var result := {}
	var subdirs := DirAccess.get_directories_at(path)
	
	for subdir in subdirs:
		var full_path := path.path_join(subdir)
		result[subdir] = get_folder_tree(full_path)
	
	return result
