extends Node3D

# Movment in the Z axis by multiplies of sin(60) <- Degrees
# Movment in the X axis by multiplies of 0.5

# This script is attached to the TileContainer scene, that can change the type of tile it holds
# and knows to calculate it's index in the grid and pass it to the grid_manager


var TILES_SCENES : Dictionary = {
	0 : preload("res://Scenes/GhostTile/ghost_tile.tscn"),
	1 : preload("res://Scenes/GrassTile/grass_tile.tscn"),
	2 : preload("res://Scenes/StoneTile/stone_tile.tscn")
}

enum TILE_TYPES {
	GHOST, GRASS, STONE
}

@onready var tile_holder = $TileHolder
@onready var label = $Label3d

signal tile_changed

var tile_type
var index : Vector2
var current_tile : Node3D
var grid_manager : Node3D

func _ready():
	if get_parent() != null:
		grid_manager = get_parent_node_3d()
		self.connect("tile_changed", grid_manager.tile_change)
	current_tile = tile_holder.get_child(0)
	tile_type = TILE_TYPES.GHOST
	calculate_index()

func calculate_index():
	var x_index = int(round(global_position.x/0.5))
	index.x = x_index
	var y_index = int(round(global_position.z/sin(deg_to_rad(60))))
	index.y = y_index
	label.text = str(index)


func tile_selected(is_left_click : bool):
	if !grid_manager.edit_mode:
		return
	if is_left_click: 
		if tile_type == grid_manager.tile_type_selected:
			return
		emit_signal("tile_changed", true, self)
		set_tile_type(grid_manager.tile_type_selected)
	else:
		if tile_type == TILE_TYPES.GHOST:
			return
		emit_signal("tile_changed", false, self)
		set_tile_type(TILE_TYPES.GHOST)

func set_tile_type(new_tile_type : int):
	var tile = TILES_SCENES[new_tile_type].instantiate()
	tile_holder.get_child(0).queue_free()
	tile_holder.remove_child(current_tile)
	tile_holder.add_child(tile)
	current_tile = tile
	tile_type = new_tile_type
	

