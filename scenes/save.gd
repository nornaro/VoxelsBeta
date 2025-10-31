@tool
extends Button

var save_dir := "res://save/"
@onready var savename:LineEdit = %SaveName
@export_tool_button("Save") var s = _on_pressed


func _ready() -> void:
	connect("pressed",_on_pressed)

func _on_pressed() -> void:
	if !savename.visible:
		%Panel.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
		savename.show()
		return

	if !savename.text:
		%Panel.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
		savename.hide()
		return
		
	if FileAccess.file_exists(save_dir+savename.text):
		savename.text = ""
		savename.tooltip_text = "File alrady exists"
		return
		
	DirAccess.make_dir_recursive_absolute(save_dir+"/"+savename.text)
	for componnet in %BuildNodes.get_children():
		save_component(componnet)
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

func save_component(component:Node3D):
	var dir = save_dir + savename.text + "/" + component.name + "/"
	DirAccess.make_dir_recursive_absolute(dir)
	component.save_component(dir)
