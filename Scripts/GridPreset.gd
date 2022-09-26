class_name Preset
extends Resource

class tile_data:
	var index : Vector2
	var tile_type : int

@export var preset_dictionary : Dictionary = {}

func save_new_tile_container(index: Vector2, type: int):

	if preset_dictionary.has(index):
		print("Index already exists")
	else:
		preset_dictionary[index] = type

