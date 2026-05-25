extends WizardPanelBase

@export var folder_icon: Texture2D
@export var structures: Array[StructureDefinition]

@onready var next_btn: Button = %NextButton
@onready var structure_option: OptionButton = %StructureOption
@onready var tree: Tree = %Tree

var _data_bag: Dictionary[String, Variant] = {}

var _tree_size_counter: int = 0

func _ready() -> void:
	for structure in structures:
		structure_option.add_item(structure.structure_name)
	structure_option.selected = 0
	_data_bag["structure_definition"] = structures[0]
	make_tree(_data_bag["structure_definition"].structure)
	structure_option.item_selected.connect(func(id: int) -> void:
		_data_bag["structure_definition"] = structures[id]
		make_tree(_data_bag["structure_definition"].structure)
		update_data.emit()
	)
	next_btn.pressed.connect(func() -> void:
		next.emit()
	)

func is_valid_data() -> bool:
	return _data_bag.has("structure_definition") and _data_bag["structure_definition"] != null

func get_data() -> Dictionary[String, Variant]:
	return _data_bag

func make_tree(structure: Dictionary) -> void:
	tree.clear()
	_tree_size_counter = 0
	var root := tree.create_item()
	tree.hide_root = true
	_make_tree_helper(root, structure)
	tree.custom_minimum_size = Vector2(0, 32.0 * _tree_size_counter)

func _make_tree_helper(tree_item: TreeItem, structure: Dictionary) -> void:
	if structure == null:
		return
	for item in structure.keys():
		_tree_size_counter += 1
		var new_item := tree_item.create_child()
		new_item.set_text(0, item)
		new_item.set_icon(0, folder_icon)
		_make_tree_helper(new_item, structure[item])
