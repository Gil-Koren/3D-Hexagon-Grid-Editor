extends PopupPanel

@onready var preset_row := preload("res://Scenes/GUI/preset_row.tscn")
const PRESETS_PATH : String = "user://Presets/"

var presets : Array

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
	presets = list_files_in_directory(PRESETS_PATH)
	_intialize_rows()

func _intialize_rows():
	var counter := 1
	for preset in presets:
		var new_row := preset_row.instantiate()
		new_row.get_node("Name").text = preset
		new_row.get_node("LoadButton").button_up.connect(_preset_selected.bind(preset))
		new_row.get_node("DeleteButton").button_up.connect(_preset_deleted.bind(preset))
		%RowsBox.add_child(new_row)
		%RowsBox.move_child(new_row,counter)
		counter += 1

func _preset_selected(selected_preset : String):
	emit_signal("preset_to_load_selected", selected_preset.rsplit(".")[0])

func _preset_deleted(selected_preset : String):
	emit_signal("preset_to_delete_selected", selected_preset)
	for row in %RowsBox.get_children():
		if row.get_child_count() != 0:
			if row.get_node("Name").text == selected_preset:
				%RowsBox.remove_child(row)
				row.queue_free()
