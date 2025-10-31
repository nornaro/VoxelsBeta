@tool
extends Node3D

func load_component(folder:String):
	for file:String in DirAccess.get_files_at(folder):
		if !file.contains(".tres"):
			continue
		add_child(load(file).instantiate())

func save_component(folder:String):
	for child: Node in get_children():
		DirAccess.make_dir_recursive_absolute(folder)
		%Save.set_ownership(self,child)
		%Save.save(folder + child.name +".tscn", child)
		#%WorldGenerator.settings.save_settings(folder + child.name +".tres",child.Data)
