extends Node2D

@onready var tutorial_popup = get_node_or_null(
    "CanvasLayer/TutorialPopup"
)


func _ready() -> void:

	print("========== CHAPTER 1 ROOM ==========")

	print("TUTORIAL POPUP: ", tutorial_popup)

	print("CURRENT TUTORIAL: ",
		get_tree().root.get_meta("current_tutorial", "")
	)

	if tutorial_popup == null:
		push_error("TutorialPopup reference is missing!")
		return

	print("TutorialPopup successfully found!")
