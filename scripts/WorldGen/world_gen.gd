extends Node

# Dependencies
@export var settings : GenerationSettings
@export_category("Dependencies")
@export var object_placer : ObjectPlacer
@export var pfinder : Pathfinder
@onready var interaction_tracker: Node3D = $"../Interaction_tracker"
@onready var chunks: Node3D = $"../../Chunks"

#UI
@onready var label: RichTextLabel = $"../../Control/VBoxContainer/RichTextLabel"
@export var loading_container: CenterContainer

const COLLIDER_SCRIPT = preload("res://scripts/WorldGen/Voxel/voxel_collider.gd")
const V_COLLIDER = preload("res://assets/Meshes/HexTileCollider.tscn")


## Starting point: Generate a random seed, create the tiles, place POI's
func _ready() -> void:
	WorldMap.clear_map()
	loading_container.visible = true
	WorldMap.world_settings = settings
	init_seed()
	var children = chunks.get_children() + get_children()
	for c in children:
		c.free()
	object_placer.clear_objects()
	call_deferred("generate_world")

# Randomize if no seed has been set
func init_seed():
	if settings.map_seed == 0 or settings.map_seed == null:
		settings.noise.seed = randi()
	else:
		settings.noise.seed = settings.map_seed


## Start of world_generation, time each step
func generate_world():
	var starttime = Time.get_ticks_msec()
	var interval = {"Start of Generation!" : starttime}
	
	## Get all positions through the gridmapper
	var mapper = GridMapper.new()
	var voxels = mapper.calculate_map_positions()
	interval["Calculate Map Positions -- "] = Time.get_ticks_msec()

	var vg = VoxelGenerator.new()
	var chunk_mesh = vg.generate_chunk(voxels, interval)
	var new_chunk = Chunk.new()
	new_chunk.material_override = settings.material
	new_chunk.mesh = chunk_mesh
	new_chunk.voxels = voxels
	chunks.add_child(new_chunk)
	interval["Create Voxel Mesh -- "] = Time.get_ticks_msec()
	
	#if settings.debug:
		#new_chunk.mesh.create_debug_tangents()
		#interval["Debugging overhead -- "] = Time.get_ticks_msec()
	
	WorldMap.set_map(vg.top_voxels)
	init_voxels(vg.top_voxels)
	interval["Generate Colliders and neighbors -- "] = Time.get_ticks_msec()

	## Spawn villages and units
	if settings.spawn_villages_and_units:
		var placeable = get_placeable_voxels()
		object_placer.place_villages(placeable, settings.spacing)
		object_placer.create_starting_units(floori(settings.radius*0.5))
		interval["Spawn Villages -- "] = Time.get_ticks_msec()
	
	print_generation_results(starttime, interval)
	interaction_tracker.init()
	loading_container.visible = false


## This mess of a function loops through the timing results of generate_world and prints them
func print_generation_results(start : float, dict : Dictionary):
	print("\n")
	label.text = ""
	var last_val = start
	var total = 0
	var unit = "ms"
	
	for key in dict:
		var val = dict[key]
		if val == start:
			#print(key)
			continue
		var passed = val - last_val
		#print(key, str(passed) + "ms")
		label.text += "[b]" + str(key) + "[/b]" + "[i]" + str(passed) + "ms\n" + "[/i]"
		last_val = val
		total += passed

	if total > 999: 
		unit = "s"
		total *= 0.001

	print("Total completion time: ", total, unit)
	label.text += "[b]Total completion time: [/b][i]" + str(total) + unit + "[/i]"


## Ignore buffer and ocean to return for object placer
func get_placeable_voxels() -> Array[Voxel]:
	var placeable_tiles : Array[Voxel] = []
	for voxel : Voxel in WorldMap.top_layer_voxels:
		if voxel.buffer or not voxel.placeable:
			continue
		placeable_tiles.append(voxel)
	print(str(placeable_tiles.size()) + " placeable tiles")
	return placeable_tiles


func init_voxels(valid_voxels):
	for voxel : Voxel in valid_voxels:
		# set neighbors
		var table = VoxelData.get_tile_neighbor_table(voxel.grid_position_xyz.x)
		for dir in table:
			var neighbor_pos = Vector2i(voxel.grid_position_xz.x + dir.x, voxel.grid_position_xz.y + dir.y)
			var neighbor = WorldMap.map_as_dict.get(neighbor_pos)
			if neighbor:
				voxel.neighbors.append(WorldMap.map_as_dict[neighbor_pos])
		
		#Add and setup colliders
		var c : StaticBody3D = V_COLLIDER.instantiate()
		c.position = voxel.world_position
		c.position.y += settings.voxel_height
		add_child(c)
		c.scale_object_local(Vector3(settings.voxel_size, 1, settings.voxel_size))
		c.set_script(COLLIDER_SCRIPT)
		c.add_to_group("voxels")
		c.voxel = voxel
		voxel.collider = c
