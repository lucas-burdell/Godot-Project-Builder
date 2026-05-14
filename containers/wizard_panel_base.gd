class_name WizardPanelBase
extends Control

@warning_ignore("unused_signal")
signal next

func is_valid_data() -> bool:
    assert(false, "This method must be implemented by the child class.")
    return false

func get_data() -> Dictionary[String, Variant]:
    assert(false, "This method must be implemented by the child class.")
    return {}