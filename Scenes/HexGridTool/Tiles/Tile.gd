extends Node3D
class_name Tile


# This is the general script for a tile, it holds basic functionality of being clicked 
# and knowing who is parent container is. Additional Script for each tile should be added
# at the speficic tile's script that extends this one.

var container : Node3D
signal tile_clicked

func _ready():
	if get_parent().get_parent() != null:
		container = get_parent().get_parent()
		self.connect("tile_clicked",container.tile_selected)
	if find_child("Area3d"):
		var area : Area3D = find_child("Area3d")
		area.input_event.connect(_on_area_3d_input_event)
	else:
		print("Couldn't find Area3d node")

func _on_area_3d_input_event(_camera, event, _event_position, _normal, _shape_idx):
	if event.is_action_pressed("left_click"):
		emit_signal("tile_clicked",true)
	elif event.is_action_pressed("right_click"):
		emit_signal("tile_clicked",false)
	else:
		return
