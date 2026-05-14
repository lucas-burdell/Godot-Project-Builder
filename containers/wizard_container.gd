extends VBoxContainer

@export var containers: Array[WizardPanelBase] = []
var data_bag: Dictionary[String, Variant] = {}

func _ready() -> void:
	_setup_containers()

func _setup_containers() -> void:
	for i in range(containers.size()):
		var child: Control = containers[i]
		assert(child != null, "container %d is null" % i)
		if i == 0:
			child.visible = true
		else:
			child.visible = false
		if child.has_signal("next"):
			child.connect("next", func() -> void:
				_handle_next(i, i + 1)
			)

func _handle_next(current_index: int, next_index: int) -> void:
	if not containers[current_index].is_valid_data():
		return
	_update_data_bag_from_container(containers[current_index])
	if (next_index) >= containers.size():
		return
	_animate_open(containers[next_index])

func _update_data_bag_from_container(container: WizardPanelBase) -> void:
	var data_to_merge := container.get_data()
	data_bag.merge(data_to_merge, true)

func _animate_open(container: Control) -> void:
	container.visible = true
