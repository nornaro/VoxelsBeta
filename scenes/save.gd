@tool
extends Button

var save_base_dir := "res://save/"
var save_dir :String
@onready var savename:LineEdit = %SaveName
@export_tool_button("Save") var s = _on_pressed


func _ready() -> void:
	connect("pressed",_on_pressed)

func _on_pressed() -> void:
	if Engine.is_editor_hint():
		save_dir = save_base_dir + str(get_instance_id())
		for component in %Builder.get_children():
			if !component.has_method("save_component"):
				continue
			save_component(component)
		return

	if !savename.visible:
		%Panel.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
		savename.show()
		return

	if !savename.text:
		%Panel.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
		savename.hide()
		return
		
	save_dir = save_base_dir + "/" + savename.text
	
	if FileAccess.file_exists(save_dir):
		savename.text = ""
		savename.tooltip_text = "File alrady exists"
		return
		
	for component:Node in %Builder.get_children():
		if !component.has_method("save_component"):
			continue
		save_component(component)
	%Panel.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	savename.hide()

func set_ownership(p_owner, node):
	for c in node.get_children():
		c.owner = p_owner
		set_ownership(p_owner, c)
		
func save(filename, node):
	set_ownership(node, node)  
	var scene = PackedScene.new()
	scene.pack(node)

	ResourceSaver.save(scene, filename);  

func save_component(component:Node):
	var dir = save_dir + "/" + component.name + "/"
	DirAccess.make_dir_recursive_absolute(dir)
	component.save_component(dir)
