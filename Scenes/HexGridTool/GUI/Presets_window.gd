extends PopupPanel

@onready var preset_row := preload("res://Scenes/HexGridTool/GUI/preset_row.tscn")
const PRESETS_PATH : String = "user://Presets/"

var presets : Array

signal save_as_pressed
signal preset_to_load_selected
signal preset_to_delete_selected

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files

func _ready():
	%SaveAsButton.button_up.connect(_on_save_as_pressed)
	intialize_rows()

func intialize_rows():
	clear_rows()
	presets = list_files_in_directory(PRESETS_PATH)
	var counter := 1
	for preset in presets:
		var new_row := preset_row.instantiate()
		new_row.get_node("Name").text = preset
		new_row.get_node("LoadButton").button_up.connect(_preset_selected.bind(preset))
		new_row.get_node("DeleteButton").button_up.connect(_preset_deleted.bind(new_row,preset))
		%RowsBox.add_child(new_row)
		%RowsBox.move_child(new_row,counter)
		counter += 1

func clear_rows():
	while true:
		var object = %RowsBox.get_child(1)
		if object.name != "SaveRow":
			%RowsBox.remove_child(object)
			object.queue_free()
		else: 
			return false

func _preset_selected(selected_preset : String):
	emit_signal("preset_to_load_selected", selected_preset.rsplit(".")[0])

func _preset_deleted(selected_preset_row, selected_preset : String):
	%RowsBox.remove_child(selected_preset_row)
	selected_preset_row.queue_free()
	emit_signal("preset_to_delete_selected", selected_preset)

func _on_save_as_pressed() -> void:
	var entered_name : String = %NameInsert.text
	emit_signal("save_as_pressed", entered_name)
