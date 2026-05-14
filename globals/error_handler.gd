extends Node


func show_fatal_error(err_msg: String) -> void:
    var err_box := AcceptDialog.new()
    err_box.dialog_text = "Godot Project Maker encountered an error and needs to close. Error: %s. The program will now exit." % err_msg
    get_tree().root.add_child(err_box)
    err_box.force_native = true
    err_box.popup_centered()
    err_box.confirmed.connect(func() -> void:
        get_tree().quit(1)
    )
