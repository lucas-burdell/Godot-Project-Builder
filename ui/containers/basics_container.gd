extends WizardPanelBase

@onready var name_edit: LineEdit = %NameEdit
@onready var godot_version_option: OptionButton = %GodotVersionOption
@onready var project_location_edit: LineEdit = %ProjectLocationEdit
@onready var project_location_button: Button = %ProjectLocationButton
@onready var project_location_dialog: FileDialog = %ProjectLocationFileDialog
@onready var csharp_checkbox: CheckButton = %CSharpCheckbox
@onready var next_btn: Button = %NextButton

var data_bag: Dictionary[String, Variant] = {}

func _ready() -> void:
	next_btn.disabled = true
	next_btn.pressed.connect(func() -> void:
		next.emit()
	)
	name_edit.text_changed.connect(func(new_text: String) -> void:
		data_bag["project_name"] = new_text
		next_btn.disabled = !_is_all_data_filled()
		update_data.emit()
	)
	_setup_godot_versions()
	godot_version_option.item_selected.connect(func(index: int) -> void:
		data_bag["project_version"] = godot_version_option.get_item_text(index)
		next_btn.disabled = !_is_all_data_filled()
		update_data.emit()
	)
	project_location_button.pressed.connect(func() -> void:
		project_location_dialog.popup_centered()
	)
	project_location_dialog.dir_selected.connect(func(dir: String) -> void:
		data_bag["project_directory"] = dir
		project_location_edit.text = dir
		next_btn.disabled = !_is_all_data_filled()
		update_data.emit()
	)
	data_bag["project_csharp"] = false
	csharp_checkbox.toggled.connect(func(on: bool) -> void:
		data_bag["project_csharp"] = on
		next_btn.disabled = !_is_all_data_filled()
		update_data.emit()
	)

func is_valid_data() -> bool:
	return _is_all_data_filled()

func get_data() -> Dictionary[String, Variant]:
	return data_bag

func _setup_godot_versions() -> void:
	var output: Array[String] = []
	var exit_code: int = 0
	if OS.get_name() == "Windows":
		exit_code = OS.execute("cmd", ["/C", "set GDVM_ALIAS=project && gdvm search"], output)
	elif OS.get_name() == "Linux" or OS.get_name() == "macOS":
		OS.execute("sh", ["-c", "export GDVM_ALIAS=project && gdvm search"], output)
	if exit_code != 0:
		PopupHandler.show_fatal_error("GDVM is not installed, not found in PATH or failed")
	var lines := output[0].replace("\r\n", "\n").split("\n")
	for line in lines:
		if not line.begins_with("-"):
			continue
		line = line.replace("- ", "").strip_edges()
		if !line.begins_with("4"):
			continue
		godot_version_option.add_item(line)
	data_bag["project_version"] = godot_version_option.get_item_text(godot_version_option.get_selected_id())

func _is_all_data_filled() -> bool:
	var required_data := ["project_name", "project_version", "project_directory"]
	for data_name in required_data:
		if data_bag.has(data_name) and data_bag.get(data_name) != null and data_bag.get(data_name) != "":
			continue
		return false
	return true
