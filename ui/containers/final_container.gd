extends WizardPanelBase

@onready var createbtn: Button = %CreateButton
@onready var readout: RichTextLabel = %Readout

func is_valid_data() -> bool:
	return true

func get_data() -> Dictionary[String, Variant]:
	return {}

func _ready() -> void:
	createbtn.pressed.connect(func() -> void:
		next.emit()
	)

func update_from_bag(databag: Dictionary[String, Variant]) -> void:
	_generate_readout(databag)
	
func _generate_readout(databag: Dictionary[String, Variant]) -> void:
	readout.text = ""
	var template := """
Project Name: [color=Yellow]%s[/color]
Project Version: [color=Yellow]%s[/color]
Project Location: [color=Yellow]%s[/color]
Project Uses C#: %s
Controller Template: [color=Yellow]%s[/color]
Folder Structure: [color=Yellow]%s[/color]
"""
	var project_name:String = databag.get("project_name", "")
	var project_version:String = databag.get("project_version", "")
	var project_directory:String = databag.get("project_directory", "").path_join(project_name)
	var project_uses_csharp:String = "[color=Green]Yes[/color]" if databag.get("project_csharp", false) else "[color=Red]No[/color]"
	var controller_name:String = databag.get("controller_name", "")
	var structure:StructureDefinition = databag.get("structure_definition", null)
	var structure_name: String = ""
	if structure != null:
		structure_name = structure.structure_name
	readout.text = template % [
		project_name,
		project_version,
		project_directory,
		project_uses_csharp,
		controller_name,
		structure_name
	]
