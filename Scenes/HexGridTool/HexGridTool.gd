extends Node3D

# Movment in the Z axis by multiplies of sin(60) <- Degrees
# Movment in the X axis by multiplies of 0.5

const TILE_CONTAINER := preload("res://Scenes/TileContainer/tile_container.tscn")

var tile_type_selected : int = 1
var edit_mode : bool = true
var tiles_dictionary : Dictionary = {}
var preset : Preset
const ADJACENTS : Array[Vector2] = [
	Vector2(1,1), Vector2(1,-1), Vector2(-1,1), Vector2(-1,-1), Vector2(2,0), Vector2(-2,0)
]

func _ready():
	pass


func initialize_grid():
	if preset.preset_dictionary.is_empty():
		add_tile(Vector2(0,0) , 0)
	else:
		clear_tiles()
		for key in preset.preset_dictionary:
			if key not in tiles_dictionary:
				add_tile(key,preset.preset_dictionary[key])
			elif preset.preset_dictionary[key] != tiles_dictionary[key].tile_type:
				remove_tile(key)
				add_tile(key,preset.preset_dictionary[key])


func tile_change(is_added : bool, changed_container : Node3D):
	var cur_index : Vector2 = changed_container.index
	if is_added:
		for offset in ADJACENTS:
			if not tiles_dictionary.has((cur_index + offset)):
				add_tile(cur_index +offset, 0)
	else:
		for offset in ADJACENTS:
			if tiles_dictionary[cur_index + offset].tile_type == 0:
				var checked_tile = tiles_dictionary[cur_index + offset]
				var non_ghost_neighbours := 0
				for offset2 in ADJACENTS:
					if tiles_dictionary.has(checked_tile.index + offset2):
						if tiles_dictionary[checked_tile.index + offset2].tile_type != 0:
							non_ghost_neighbours += 1
				if non_ghost_neighbours == 1:
					remove_tile(cur_index + offset)
		recheck_ghost_tile(cur_index)
	
	if tiles_dictionary.is_empty():
		add_tile(Vector2.ZERO,0)

func add_tile(index : Vector2, tile_type : int):
	var tile = TILE_CONTAINER.instantiate()
	tile.position.x = index.x * 0.5 
	tile.position.z = index.y * sin(deg_to_rad(60))	
	add_child(tile)
	tile.set_tile_type(tile_type)
 
	tiles_dictionary[index] = tile


func remove_tile(index : Vector2):
	tiles_dictionary[index].queue_free()
	remove_child(tiles_dictionary[index])
	tiles_dictionary.erase(index)

func recheck_ghost_tile(index : Vector2):
	var checked_tile = tiles_dictionary[index]
	var non_ghost_neighbours := 0
	for offset in ADJACENTS:
		if tiles_dictionary.has(checked_tile.index + offset):
			if tiles_dictionary[checked_tile.index + offset].tile_type != 0:
				non_ghost_neighbours += 1
	if non_ghost_neighbours == 0:
		remove_tile(index)

func clear_tiles() -> void:
	for index in tiles_dictionary.keys():
		remove_tile(index)

func new_tile_type_selected(tile_type_enum : int):
	tile_type_selected = tile_type_enum

