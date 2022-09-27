extends Node3D

# Movment in the Z axis by multiplies of sin(60) <- Degrees
# Movment in the X axis by multiplies of 0.5

const TILE_CONTAINER := preload("res://Scenes/HexGridTool/TileContainer/tile_container.tscn")

@onready var presets_window := preload("res://Scenes/HexGridTool/GUI/Presets_window.tscn")
var presets_window_instance : PopupPanel
var _save : SaveGame
var preset : Preset

var tile_type_selected : int = 1
var edit_mode : bool = true
var tiles_dictionary : Dictionary = {}

const ADJACENTS : Array[Vector2] = [
	Vector2(1,1), Vector2(1,-1), Vector2(-1,1), Vector2(-1,-1), Vector2(2,0), Vector2(-2,0)
]

signal window_opened
signal window_closed

func _ready(): # This makes sure the grid starts with an initial tile
	add_tile(Vector2.ZERO,0)


func initialize_grid():
	if preset.preset_dictionary.is_empty(): # Prevents loading an empty preset
		clear_tiles()
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
	
	if tiles_dictionary.is_empty(): # Makes sure there is atleast 1 ghost tile
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

func clear_grid(): 
	clear_tiles()
	add_tile(Vector2(0,0),0)

func load_preset(preset_name : String): 
	_save = SaveGame.load_savegame(preset_name)
	preset = _save.preset
	initialize_grid()

func delete_preset(selected_preset : String): 
	var dir = Directory.new()
	dir.open("user://Presets/")
	dir.remove(selected_preset)

func show_custom_save_menu(): 
	var new_window : PopupPanel= presets_window.instantiate()
	new_window.connect("preset_to_load_selected",load_preset)
	new_window.connect("preset_to_delete_selected",delete_preset)
	new_window.connect("save_as_pressed", _save_preset_as)
	new_window.connect("close_requested",func():emit_signal("window_closed"))
	emit_signal("window_opened")
	add_child(new_window)
	new_window.popup_centered()
	presets_window_instance = new_window

func _save_preset_as(entered_name : String): 
	var new_save = SaveGame.new()
	var new_preset = Preset.new()
	for key in tiles_dictionary:
		new_preset.save_new_tile_container(key,tiles_dictionary[key].tile_type)
	new_save.preset = new_preset
	if SaveGame.save_exists(entered_name):
		delete_preset(entered_name)
	new_save.write_savegame(entered_name)
	presets_window_instance.intialize_rows()

