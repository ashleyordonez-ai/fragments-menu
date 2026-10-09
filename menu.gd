extends Control



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/ChapterSelection.tscn")

func _on_options_pressed() -> void:
	print("options")

func _on_exit_pressed() -> void:
	print("exit")
