class_name ProjectBuilder
extends RefCounted

var _data_bag: Dictionary[String, Variant]

func _init(databag: Dictionary[String, Variant]) -> void:
	_data_bag = databag

func create() -> void:
	var dir := DirAccess.open(_data_bag["project_directory"])
	if dir.dir_exists(_data_bag["project_name"]):
		PopupHandler.show_warning("Project folder already exists at %s" % (_data_bag["project_directory"] + " " + _data_bag["project_name"]))
		return
	dir.make_dir(_data_bag["project_name"])
	var project_dir := dir.get_current_dir().path_join(_data_bag["project_name"])
	var project_file_path := project_dir.path_join("project.godot")
	var project_file := FileAccess.open(project_file_path, FileAccess.WRITE_READ)
	if project_file == null:
		PopupHandler.show_warning("Error opening project file %s. Error code %d" % [project_file_path, FileAccess.get_open_error()])
		return
	project_file.store_string("""
config_version=5
%s
%s
%s
%s
""" % [_gen_proj_application_header(), _gen_proj_input_header(), _gen_proj_physics_header(), _gen_proj_rendering_header()])
	project_file.close()
	_copy_file("res://icon.svg", project_dir.path_join("icon.svg"))
	_write_file(project_dir.path_join(".gitignore"), """
# Godot 4+ specific ignores
.godot/
/android/
""")
	_write_file(project_dir.path_join(".gitattributes"), """
# Normalize EOL for all files that Git considers text files.
* text=auto eol=lf
""")
	_write_file(project_dir.path_join(".editorconfig"), """
root = true

[*]
charset = utf-8
""")
	_generate_project_structure(project_dir)
	_copy_controller(project_dir)

func _copy_file(from: String, to: String) -> void:
	var from_file_bytes := FileAccess.get_file_as_bytes(from)
	var to_file := FileAccess.open(to, FileAccess.WRITE)
	to_file.store_buffer(from_file_bytes)
	to_file.close()

func _write_file(to: String, text: String) -> void:
	var to_file := FileAccess.open(to, FileAccess.WRITE)
	to_file.store_string(text)
	to_file.close()

func _generate_project_structure(project_dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(project_dir.path_join("addons"))
	var structure_def: StructureDefinition = _data_bag["structure_definition"]
	var structure := structure_def.structure
	_generate_project_structure_folders(project_dir, structure)
	
func _generate_project_structure_folders(dir: String, structure_dict: Dictionary) -> void:
	if structure_dict == null:
		return
	for folder in structure_dict.keys():
		DirAccess.make_dir_recursive_absolute(dir.path_join(folder))
		_write_file(dir.path_join(folder).path_join(".empty"), "")
		_generate_project_structure_folders(dir.path_join(folder), structure_dict[folder])


func _copy_controller(project_dir: String) -> void:
	var controller_dir := DirAccess.open(_data_bag["controller_path"])
	var new_location := project_dir.path_join(_data_bag["structure_definition"].controller_location)
	var project_dir_access := DirAccess.open(new_location)
	project_dir_access.make_dir(_data_bag["controller_name"])
	for child in controller_dir.get_files():
		var file_bytes := FileAccess.get_file_as_bytes(_data_bag["controller_path"].path_join(child))
		var file_access := FileAccess.open(new_location.path_join(_data_bag["controller_name"]).path_join(child), FileAccess.WRITE)
		file_access.store_buffer(file_bytes)
		file_access.close()

func _gen_proj_application_header() -> String:
	return """
[application]

config/name="%s"
config/features=PackedStringArray("%s", "Forward Plus")
config/icon="res://icon.svg"
""" % [_data_bag["project_name"], _data_bag["project_version"]]

func _gen_proj_input_header() -> String:
	return """
[input]

player_jump={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":32,"key_label":0,"unicode":32,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":0,"pressure":0.0,"pressed":true,"script":null)
]
}
player_left={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":65,"key_label":0,"unicode":97,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":0,"axis_value":-1.0,"script":null)
]
}
player_right={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":68,"key_label":0,"unicode":100,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":0,"axis_value":1.0,"script":null)
]
}
player_forward={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":87,"key_label":0,"unicode":119,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":1,"axis_value":-1.0,"script":null)
]
}
player_backward={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":83,"key_label":0,"unicode":115,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":1,"axis_value":1.0,"script":null)
]
}
player_lean_left={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":81,"key_label":0,"unicode":113,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":9,"pressure":0.0,"pressed":true,"script":null)
]
}
player_lean_right={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":69,"key_label":0,"unicode":101,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":10,"pressure":0.0,"pressed":true,"script":null)
]
}
player_crouch={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194326,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":1,"pressure":0.0,"pressed":true,"script":null)
]
}
player_sprint={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194325,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":7,"pressure":0.0,"pressed":true,"script":null)
]
}
camera_left={
"deadzone": 0.2,
"events": [Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":2,"axis_value":-1.0,"script":null)
]
}
camera_right={
"deadzone": 0.2,
"events": [Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":2,"axis_value":1.0,"script":null)
]
}
camera_up={
"deadzone": 0.2,
"events": [Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":3,"axis_value":-1.0,"script":null)
]
}
camera_down={
"deadzone": 0.2,
"events": [Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":3,"axis_value":1.0,"script":null)
]
}
game_pause={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194305,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":6,"pressure":0.0,"pressed":true,"script":null)
]
}
"""

func _gen_proj_physics_header() -> String:
	return """
[physics]

3d/physics_engine="Jolt Physics"
"""

func _gen_proj_rendering_header() -> String:
	return """
[rendering]

rendering_device/driver.windows="d3d12"
"""
