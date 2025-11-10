@tool
extends Node3D

enum mode {SELECT, BUILD}
var interact_mode : mode = mode.SELECT
@export var voxel_cursor_scene : PackedScene
@export var unit_cursor_scene : PackedScene
@export var main_camera : Camera3D
@export var p_finder : Pathfinder
@export var selection_indicator : TextureRect
const BUILDSPRITE = preload("uid://cgpb4pbfvd0q3")
const SELECTSPRITE = preload("uid://cctpnojcm20kn")

var selected_voxel : Voxel
var selected_unit : Unit
var unit_moves : Array[Voxel]
# Cursors
var voxel_cursor : StaticBody3D
var unit_cursor : Node3D
var initialized = false
var selected
@onready var default_hexcursor_mat = preload("res://assets/Materials/hex_cursor_mat.tres")
@onready var default_hexcursor_res = preload("res://assets/Meshes/hex_cursor.res")
var key_pressed: Dictionary = {}
var highlighted:Array

func init():
	if initialized:
		return
	if not voxel_cursor or voxel_cursor == null:
		voxel_cursor = voxel_cursor_scene.instantiate()
		add_child(voxel_cursor)
	if not unit_cursor:
		unit_cursor = unit_cursor_scene.instantiate()
		add_child(unit_cursor)
	
	var scalar = WorldMap.world_settings.voxel_size
	voxel_cursor.scale_object_local(Vector3(scalar, 1.0, scalar))
	deselect()
	selection_indicator.texture = SELECTSPRITE
	initialized = true

func _ready() -> void:
	selection_indicator = $"../../Control/TextureRect"

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if EditorInterface.get_selection().get_selected_nodes().is_empty():
			return
		if EditorInterface.get_selection().get_selected_nodes()[0] is not CollisionObject3D:
			return
		selected = EditorInterface.get_selection().get_selected_nodes()[0]
		editor_input()
		return
	runtime_input()
	mode_select()
	setup_raycast()

func runtime_input():
	if !selected:
		return
	var cursorres:MeshInstance3D = get_tree().get_first_node_in_group("hexcursorres")
	if Input.is_key_pressed(KEY_SHIFT):
		if is_key_just_pressed(KEY_A):
			voxel_cursor.rotation.y -= deg_to_rad(30)
		if is_key_just_pressed(KEY_D):
			voxel_cursor.rotation.y += deg_to_rad(30)
		if is_key_just_pressed(KEY_S):
			voxel_cursor.position.y -= 1
		if is_key_just_pressed(KEY_W):
			voxel_cursor.position.y += 1
		if is_key_just_pressed(KEY_KP_ADD):
			cursorres.scale += Vector3(0.1,0.1,0.1)
			%Label.show_text("Scale: " + str(roundf(cursorres.scale.x * 10.0) / 10.0))
		if is_key_just_pressed(KEY_KP_SUBTRACT):
			cursorres.scale -= Vector3(0.1,0.1,0.1)
			%Label.show_text("Scale: " + str(roundf(cursorres.scale.x * 10.0) / 10.0))
			

func editor_input() -> void:
	if !selected:
		return
	if Input.is_key_pressed(KEY_SHIFT):
		if is_key_just_pressed(KEY_A):
			selected.rotation.y -= deg_to_rad(30)
		if is_key_just_pressed(KEY_D):
			selected.rotation.y += deg_to_rad(30)
		if is_key_just_pressed(KEY_S):
			selected.position.y -= 1
		if is_key_just_pressed(KEY_W):
			selected.position.y += 1
	var pointer = Vector2i( roundi(selected.global_position.x),roundi(selected.global_position.z))
	if !WorldMap.map_xz_dict.has(pointer):
		return
	selected.global_position.x = WorldMap.map_xz_dict[pointer].x
	selected.global_position.z = WorldMap.map_xz_dict[pointer].z


func is_key_just_pressed(key_code: Key) -> bool:
	var is_pressed := Input.is_key_pressed(key_code)

	if is_pressed and not key_pressed.get(key_code, false):
		key_pressed[key_code] = true
		return true

	key_pressed[key_code] = is_pressed
	return false


func is_key_just_released(key_code: Key) -> bool:
	var is_pressed := Input.is_key_pressed(key_code)

	if not is_pressed and key_pressed.get(key_code, false):
		key_pressed[key_code] = false
		return true

	key_pressed[key_code] = is_pressed
	return false

func mode_select() -> void:
	if Input.is_action_just_pressed("Build"):
		interact_mode = mode.BUILD
		selection_indicator.texture = BUILDSPRITE
	if Input.is_action_just_pressed("Select"):
		interact_mode = mode.SELECT
		selection_indicator.texture = SELECTSPRITE
		
func setup_raycast() -> void:
	if !Input.is_action_just_pressed("Click") and Input.is_action_just_pressed("RightClick"):
		return
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = main_camera.project_ray_origin(mouse_pos)
	var dir = main_camera.project_ray_normal(mouse_pos)
	var end = origin + dir * 1000
	var hit_data:HitData = raycast_at_mouse(origin, end)
	if hit_data:
		runtime_only_input(hit_data)
	#print("hit data is empty")
	return

func runtime_only_input(hit_data) -> void:
		if Input.is_action_just_pressed("Click"):
			if interact_mode == mode.SELECT:
				attempt_select(hit_data)
			if interact_mode == mode.BUILD:
				attempt_build(hit_data.object)
		if Input.is_action_just_pressed("RightClick"):
			attempt_move_unit(hit_data)


func raycast_at_mouse(origin, end) -> HitData:
	if Engine.is_editor_hint():
		return
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	if !collision or !collision.has("collider"):
		deselect()
		return null
	var hit = collision.collider
	var data = HitData.new()
	data.object = hit
	data.point = collision.position
	data.normal = collision.normal
	return data


func attempt_build(hit_object):
	if hit_object.is_in_group("voxels"):
		build_voxel(hit_object)


func build_voxel(hit_object):
	print(hit_object)


func deselect():
	#hide_cursor(voxel_cursor)
	#hide_cursor(unit_cursor)
	unit_moves.clear()
	selected_unit = null
	p_finder.clear_highlight()


func attempt_select(hit: HitData):
	deselect()
	if (hit.object.is_in_group("Hex") or hit.object.get_parent().is_in_group("Hex")):
		highlight_hex(hit)
		return
	if (hit.object.is_in_group("voxels") or hit.object.get_parent().is_in_group("voxels")):
		highlight_voxel(hit)
		return
	if hit.object.is_in_group("units") or hit.object.is_in_group("Building"):
		select_unit(hit.object)
	elif hit.object.get_parent().is_in_group("units"):
		select_unit(hit.object.get_parent())


func attempt_move_unit(hitdata : HitData):
	if not selected_unit:
		print("Select a unit first")
		return
	
	var hit_chunk : Chunk = hitdata.object.get_parent()
	var hit_voxel : Voxel = hit_chunk.voxel_at_point(hitdata)
	if hit_voxel == null:
		print("Hit voxel is null!")
		return
	
	if unit_moves.has(hit_voxel):
		selected_unit.place_unit(hit_voxel)
	else:
		print("Invalid Voxel")
	deselect()


func select_unit(unit : Unit):
	selected_voxel = null
	selected_unit = unit
	hide_cursor(voxel_cursor)
	if unit is Unit:
		highlight_unit(unit)
		#unit_moves = p_finder.find_reachable_voxels(unit.occupied_voxel, unit)
		p_finder.highlight_voxel(unit_moves)


# We have clicked somewhere on a chunk of voxels
func highlight_voxel(hit: HitData): #hit is hit_data
	selected_unit = null
	hide_cursor(unit_cursor)
	var hit_chunk : Chunk = hit.object.get_parent()
	var hit_voxel : Voxel = hit_chunk.voxel_at_point(hit)
	if hit_voxel == null:
		print("Hit voxel is null!")
		return
	selected_voxel = hit_voxel
	add_highlighted(hit_voxel)
	move_cursor(voxel_cursor, hit_voxel.world_position, hit_voxel.yoffset)
	voxel_cursor.visible = true
	voxel_cursor.top_level = true
	animate_cursor(voxel_cursor)

# We have clicked somewhere on a chunk of voxels
func highlight_hex(hit: HitData): #hit is hit_data
	selected_unit = null
	hide_cursor(unit_cursor)
	#var hit_chunk: = hit.object.get_parent()
	var hit_hex : Voxel = hit.object
	if hit_hex == null:
		return
	selected_voxel = hit_hex
	add_highlighted(hit_hex)
	move_cursor(voxel_cursor, hit_hex.global_position, hit_hex.yoffset)
	voxel_cursor.visible = true
	voxel_cursor.top_level = true
	animate_cursor(voxel_cursor)


func highlight_unit(unit):
	move_cursor(unit_cursor, unit.position)
	unit_cursor.visible = true
	add_highlighted(unit)
	
func add_highlighted(h):
	highlighted.clear()
	highlighted.append(h)


## move cursor with optional height difference
func move_cursor(cursor : Node3D, pos : Vector3, height : float = 0):
	cursor.position = pos
	if height != 0:
		voxel_cursor.position.y += height


func animate_cursor(cursor : Node3D):
	var tween = get_tree().create_tween()
	var initial_scale = Vector3.ONE #cursor.scale
	var target_scale = initial_scale * 1.15
	tween.set_trans(Tween.TRANS_SPRING)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(cursor, "scale", target_scale, 0.175)
	tween.tween_property(cursor, "scale", initial_scale, 0.2)


func hide_cursor(cursor : Node3D):
	if cursor:
		#move_cursor(cursor, Vector3.ZERO, -10)
		cursor.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("ui_text_delete"):
			for item in highlighted:
				item.queue_free()
			highlighted.clear()
		return
	if event is not InputEventMouseButton:
		return
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.double_click:
		var parent:Node = %Other
		for child in %Builder.get_children():
			if !selected:
				return
			if selected.resource_path.to_lower().contains(child.name.to_lower()+"_"):
				parent = child
		var instance:Node3D = selected.instantiate()
		var mat:StandardMaterial3D = instance.get_child(0).get_active_material(0).duplicate()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		mat.albedo_color.a = 1
		instance.get_child(0).set_surface_override_material(0, mat)
		instance.position = voxel_cursor.position
		instance.rotation = voxel_cursor.rotation
		instance.add_to_group(parent.name)
		instance.name = str(instance.get_instance_id())
		instance.scale = get_tree().get_first_node_in_group("hexcursorres").scale
		var script = "res://scripts/"+parent.name.to_lower()+".gd"
		if FileAccess.file_exists(script):
			instance.set_script(load(script))
			if instance.has_method("place_unit"):
				instance.place_unit()
		parent.add_child(instance)
		return
	if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		reset_cursor()
		
func reset_cursor():
	var cursorres:MeshInstance3D = get_tree().get_first_node_in_group("hexcursorres")
	cursorres.scale = Vector3.ONE
	voxel_cursor.rotation.y = 0
	voxel_cursor.position.y = 0
	cursorres.mesh = default_hexcursor_res
	cursorres.set_surface_override_material(0, default_hexcursor_mat)
	var mat = cursorres.get_active_material(0)
	cursorres.rotation.y = 0
	cursorres.position.y = 0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.75
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	selected = null
	
