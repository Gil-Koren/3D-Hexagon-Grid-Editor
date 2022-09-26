extends Node3D

@onready var HexGrid := $HexGridTool
var _save : SaveGame
var current_save_name : String = "Deafult"
@onready var presets_window := preload("res://Scenes/GUI/Presets_window.tscn")
@onready var camera_control := $CameraController

signal save_inited

func _ready():
	%PresetsMenuButton.connect("button_up",_show_custom_save_menu)
	%ClearButton.connect("button_up",_clear_grid)
	%SaveAsButton.connect("button_up", _save_preset_as)
	%GrassType.connect("button_up", HexGrid.new_tile_type_selected.bind(1))
	%StoneType.connect("button_up", HexGrid.new_tile_type_selected.bind(2))
	%EditModeButton.connect("button_up", func(): HexGrid.edit_mode = %EditModeButton.button_pressed)
	%LineEdit.connect("focus_entered", func():camera_control.set_process(false))
	%LineEdit.connect("focus_exited", func():camera_control.set_process(true))
	connect("save_inited",HexGrid.initialize_grid)
	HexGrid.add_tile(Vector2.ZERO,0)

func _clear_grid():
	HexGrid.clear_tiles()
	HexGrid.add_tile(Vector2(0,0),0)

func _show_custom_save_menu():
	var new_window : PopupPanel= presets_window.instantiate()
	new_window.connect("preset_to_load_selected",_load_preset)
	new_window.connect("preset_to_delete_selected",_delete_preset)
	add_child(new_window)
	new_window.popup_centered()

func _save_preset_as():
	var new_save = SaveGame.new()
	var new_preset = Preset.new()
	for key in HexGrid.tiles_dictionary:
		new_preset.save_new_tile_container(key,HexGrid.tiles_dictionary[key].tile_type)
	new_save.preset = new_preset
	if SaveGame.save_exists(%LineEdit.text):
		_delete_preset(%LineEdit.text)
	new_save.write_savegame(%LineEdit.text)


func _load_preset(preset_name : String):
	_save = SaveGame.load_savegame(preset_name)
	HexGrid.preset = _save.preset
	emit_signal("save_inited")

func _delete_preset(selected_preset : String):
	var dir = Directory.new()
	dir.open("user://Presets/")
	dir.remove(selected_preset)
	
