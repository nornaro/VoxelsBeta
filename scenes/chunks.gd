@tool
extends Node3D


func load_component(folder:String):
	for file:String in DirAccess.get_files_at(folder):
		if !file.contains(".tres"):
			continue
		%WorldGenerator.settings = load(folder + file)
		%WorldGenerator.settings.map_seed = file.split(".")[0]
		%WorldGenerator.load_map()
		%Settings._ready()

func save_component(folder:String):
	for child: Node in get_children():
		DirAccess.make_dir_recursive_absolute(folder)
		%Save.set_ownership(self,child)
		%Save.save(folder + str(child.get_meta("seed")) +".scn", child)
		%WorldGenerator.settings.map_seed = child.get_meta("seed")
		%WorldGenerator.settings.noise.seed = child.get_meta("seed")
		%WorldGenerator.settings.save_settings(folder+name + str(child.get_meta("seed")) +".tres")
