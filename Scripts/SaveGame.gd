class_name SaveGame
extends Resource


const SAVE_GAME_BASE_PATH := "user://Presets/"

@export var preset : Resource = Preset.new()

func write_savegame(custom_name : String) -> void:
	ResourceSaver.save(self, get_save_path(custom_name))
	

static func load_savegame(custom_name : String) -> Resource:
	var save_path := get_save_path(custom_name)
	return ResourceLoader.load(save_path, "", true)

static func save_exists(custom_name : String) -> bool:
	return ResourceLoader.exists(get_save_path(custom_name))

static func get_save_path(custom_name : String) -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_BASE_PATH + custom_name + extension
