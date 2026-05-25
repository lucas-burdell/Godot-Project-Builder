class_name WizardPanelBase
extends Control

@warning_ignore("unused_signal")
signal next

@warning_ignore("unused_signal")
signal update_data

func is_valid_data() -> bool:
	assert(false, "This method must be implemented by the child class.")
	return false

func get_data() -> Dictionary[String, Variant]:
	assert(false, "This method must be implemented by the child class.")
	return {}

func update_from_bag(bag: Dictionary[String, Variant]) -> void:
	pass
