@tool
extends Node3D

func load_component(folder:String):
	for file:String in DirAccess.get_files_at(folder):
		if !file.contains(".tres"):
			continue
		var instance:CollisionObject3D = load(file).instantiate()
		add_child(instance)

func save_component(folder:String):
	for child: Node in get_children():
		DirAccess.make_dir_recursive_absolute(folder)
		%Save.set_ownership(self,child)
		%Save.save(folder + str(child.seed) +".tscn", child)
		#%WorldGenerator.settings.save_settings(folder + str(child.seed) +".tres",child.Data)
