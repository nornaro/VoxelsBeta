@tool
extends Node3D

func load_component(folder:String):
	for child in get_children():
		child.queue_free()
	for file:String in DirAccess.get_files_at(folder):
		if !file.contains(".tscn"):
			continue
		var instance:Node3D = load(folder+file).instantiate()
		var script = "res://scripts/"+name.to_lower()+".gd"
		if FileAccess.file_exists(script):
			instance.set_script(load(script))
		add_child(instance)

func save_component(folder:String):
	for child: Node in get_children():
		DirAccess.make_dir_recursive_absolute(folder)
		%Save.set_ownership(self,child)
		%Save.save(folder + child.name +".tscn", child)

func clear_objects():
	var children = get_children()
	for c in children:
		c.free()
