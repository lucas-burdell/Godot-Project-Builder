extends WizardPanelBase

@onready var createbtn: Button = %CreateButton
@onready var readout: Label = %Readout

func is_valid_data() -> bool:
	return true

func get_data() -> Dictionary[String, Variant]:
	return {}

func _ready() -> void:
	createbtn.pressed.connect(func() -> void:
		next.emit()
	)
