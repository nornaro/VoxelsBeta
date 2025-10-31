@tool
extends Button

@export_tool_button("Load") var l =  _on_pressed
#@export var settings = GenerationSettings
var save_dir := "res://save/"
@export_dir() var d:String

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	connect("pressed",_on_pressed)

func _on_pressed() -> void:
	if Engine.is_editor_hint():
		save_dir = d + "/"
	if !%LoadList.visible and !Engine.is_editor_hint():
		%LoadList.clear()
		for dir:String in DirAccess.get_directories_at(save_dir):
			%LoadList.add_item(dir)
		%LoadList.show()
		%Panel.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
		return
	DirAccess.make_dir_recursive_absolute(save_dir)
	iterate_components()
	
func iterate_components() -> void:
	if Engine.is_editor_hint():
		for component in %BuildNodes.get_children():
			print(d+"/"+component.name+"/")
			component.load_component(d+"/"+component.name+"/")
			continue
	for component in %BuildNodes.get_children():
		load_component(component)
		
func load_component(component:Node):
	if !%LoadList.get_selected_items():
		%LoadList.hide()
		return
	for child: Node in component.get_children():
		child.queue_free()
	%LoadList.hide()
	%Panel.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	var selected:int = %LoadList.get_selected_items()[0]
	var folder = save_dir + "/" + %LoadList.get_item_text(selected) + "/"+component.name+"/"
	component.load_component(folder)

func _load_in_editor() -> void:
	print("T")
	#if !Engine.is_editor_hint():
		#return
	#%WorldGenerator.settings = settings
	#%WorldGenerator.load_map()
