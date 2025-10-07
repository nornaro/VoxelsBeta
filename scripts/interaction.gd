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

var selected_voxel : Node3D
var selected_unit : Unit
var unit_moves : Array[Voxel]
# Cursors
var voxel_cursor : Node3D
var unit_cursor : Node3D
var initialized = false

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


func _input(event: InputEvent) -> void:
	#mode select
	if event is InputEventKey: 
		if event.is_action("Build"):
			interact_mode = mode.BUILD
			selection_indicator.texture = BUILDSPRITE
		elif event.is_action("Select"):
			interact_mode = mode.SELECT
			selection_indicator.texture = SELECTSPRITE
		
	# Setup raycast
	if event is InputEventMouseButton and event.is_pressed():
		var mouse_pos = get_viewport().get_mouse_position()
		var origin = main_camera.project_ray_origin(mouse_pos)
		var dir = main_camera.project_ray_normal(mouse_pos)
		var end = origin + dir * 1000
		var hit_data = raycast_at_mouse(origin, end) #returns the collider
		if not hit_data:
			print("hit data is empty")
			return
		
		#Click event
		if Input.is_action_just_pressed("Click"):
			if interact_mode == mode.SELECT:
				attempt_select(hit_data)
			elif interact_mode == mode.BUILD:
				attempt_build(hit_data.object)
		elif Input.is_action_just_pressed("RightClick"):
			attempt_move_unit(hit_data.object)


func raycast_at_mouse(origin, end) -> HitData:
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		var collision = get_world_3d().direct_space_state.intersect_ray(query)
		if collision and collision.has("collider"):
			var hit = collision.collider
			var data = HitData.new()
			data.object = hit
			data.point = collision.position
			data.normal = collision.normal
			return data
		else:
			deselect()
			return null


func attempt_build(hit_object):
	if hit_object.is_in_group("voxels"):
		build_voxel(hit_object)


func build_voxel(hit_object):
	print(hit_object)


func deselect():
	hide_cursor(voxel_cursor)
	hide_cursor(unit_cursor)
	unit_moves.clear()
	selected_unit = null
	p_finder.clear_highlight()


func attempt_select(hit: HitData): #hit is a HitData
	deselect()
	if hit.object.is_in_group("voxels") or hit.object.get_parent().is_in_group("voxels"):
		highlight_voxel(hit)
		return
	if hit.object.is_in_group("units"):
		select_unit(hit.object)
	elif hit.object.get_parent().is_in_group("units"):
		select_unit(hit.object.get_parent())


func attempt_move_unit(hit_collider):
	#if hit_collider is not VoxelCollider:
		#print("not a voxelcollider")
		#return
	if not selected_unit or not unit_moves.has(hit_collider.voxel):
		print("Invalid Move Attempt")
		return
	var voxel: Voxel = hit_collider.voxel
	selected_unit.place_unit(voxel)
	deselect()


func select_unit(unit : Unit):
	selected_voxel = null
	selected_unit = unit
	hide_cursor(voxel_cursor)
	if unit is Unit:
		highlight_unit(unit)
		unit_moves = p_finder.find_reachable_voxels(unit.occupied_voxel, unit.movement_range, unit.max_height_movement)
		p_finder.highlight_voxel(unit_moves)


# We have clicked somewhere on a chunk of voxels
func highlight_voxel(hit: HitData): #hit is hit_data
	selected_unit = null
	hide_cursor(unit_cursor)
	var hit_chunk : Chunk = hit.object.get_parent()
	var hit_voxel : Voxel = hit_chunk.voxel_at_point(hit.point)
	if hit_voxel == null:
		print("Hit voxel is null!")
		return
	move_cursor(voxel_cursor, hit_voxel.world_position, 1)
	voxel_cursor.visible = true
	animate_cursor(voxel_cursor)


func highlight_unit(unit):
	move_cursor(unit_cursor, unit.position)
	unit_cursor.visible = true


## move cursor with optional height difference
func move_cursor(cursor : Node3D, pos : Vector3, height : float = 0):
	cursor.position = pos
	if height != 0:
		voxel_cursor.position.y += height


func animate_cursor(cursor : Node3D):
	var tween = get_tree().create_tween()
	var initial_scale = cursor.scale
	var target_scale = initial_scale * 1.15
	tween.set_trans(Tween.TRANS_SPRING)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(cursor, "scale", target_scale, 0.175)
	tween.tween_property(cursor, "scale", initial_scale, 0.2)


func hide_cursor(cursor : Node3D):
	if cursor:
		move_cursor(cursor, Vector3.ZERO, -10)
		cursor.visible = false
