extends WizardPanelBase

@export_dir var controller_samples: String = "res://controller_examples"

@onready var controller_options: OptionButton = %ControllerOption
@onready var next_btn: Button = %NextButton

var controllers: Dictionary[String, String] = {}


func _ready() -> void:
	# get controllers
	var controllers_dir := DirAccess.open(controller_samples)
	for category in controllers_dir.get_directories():
		var category_dir := DirAccess.open(controller_samples.path_join(category))
		controller_options.add_separator(category)
		for controller_name in category_dir.get_directories():
			controllers.set(controller_name, controller_samples.path_join(category).path_join(controller_name))
			controller_options.add_item(controller_name)
		
	controller_options.item_selected.connect(func(_item: int) -> void:
		next_btn.disabled = !is_valid_data()
		update_data.emit()
	)
	next_btn.disabled = !is_valid_data()
	
	next_btn.pressed.connect(func() -> void:
		next.emit()
	)

func is_valid_data() -> bool:
	return !get_data().keys().is_empty()

func get_data() -> Dictionary[String, Variant]:
	var controller_name :String = controller_options.get_item_text(controller_options.selected)
	if !controllers.has(controller_name):
		return {}
	var controller_path := controllers[controller_name]
	return {"controller_path": controller_path, "controller_name": controller_name}
