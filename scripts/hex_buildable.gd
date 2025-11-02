extends TextureButton

func _ready() -> void:
	connect("pressed",_on_pressed)

func _on_pressed():
	var res:Resource = load(tooltip_text.replace(".tscn",".res"))
	var cursorres:MeshInstance3D = get_tree().get_first_node_in_group("hexcursorres")
	#cursor.rotation.y = deg_to_rad(30)
	cursorres.rotation.y = deg_to_rad(30)
	cursorres.mesh = res
	#cursor.position.y = -1
	#if name.begins_with("building_"):
	#cursorres.position.y = 0
	if name.begins_with("hex_"):
		cursorres.position.y = 1
	cursorres.set_surface_override_material(0, res)
	var mat = cursorres.get_active_material(0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.75
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	get_tree().get_first_node_in_group("Interaction_tracker").selected = Scenelib.lib[name]
