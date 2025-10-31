@tool
extends StaticBody3D
class_name KayKitDemoBuilding

## Just for demon, using one of the best available kits for this

func _ready():
	for child in get_children():
		if child is MeshInstance3D:
			rotation.y = 30
			child.create_multiple_convex_collisions()
