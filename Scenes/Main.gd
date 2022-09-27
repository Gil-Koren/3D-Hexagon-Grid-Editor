extends Node3D

@onready var HexGrid := $HexGridTool

@onready var camera_control := $CameraController


func _ready():
	%PresetsMenuButton.connect("button_up",HexGrid.show_custom_save_menu)
	%ClearButton.connect("button_up",HexGrid.clear_grid)
	%GrassType.connect("button_up", HexGrid.new_tile_type_selected.bind(1))
	%StoneType.connect("button_up", HexGrid.new_tile_type_selected.bind(2))
	%EditModeButton.connect("button_up", func(): HexGrid.edit_mode = %EditModeButton.button_pressed)
	HexGrid.connect("window_opened", func(): camera_control.set_process(false))
	HexGrid.connect("window_closed", func(): camera_control.set_process(true))







