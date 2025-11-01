extends TextureButton

var res:Resource

func _ready() -> void:
	connect("pressed",_on_pressed)

func _on_pressed():
	res = load(tooltip_text.replace(".tscn",".res"))
	var mesh_instance = get_tree().get_first_node_in_group("hexcursor")
	mesh_instance.mesh = res
	mesh_instance.rotation.y = deg_to_rad(30)
	mesh_instance.get_parent().position.y = 0
	if name.begins_with("hex_"):
		mesh_instance.get_parent().position.y = 1
	mesh_instance.set_surface_override_material(0, res)
	var mat = mesh_instance.get_active_material(0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.75
	mat.force_transparent = true
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	get_tree().get_first_node_in_group("Interaction_tracker").selected = mesh_instance.get_parent()
