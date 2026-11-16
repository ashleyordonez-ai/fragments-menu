
extends Node2D

@onready var tutorial_popup = get_node_or_null("CanvasLayer/TutorialPopup")


func _ready() -> void:
	print("MAIN SCENE: ", get_path())
	print("TUTORIAL POPUP: ", tutorial_popup)

	if tutorial_popup == null:
		print("ERROR: TutorialPopup reference is missing!")
		return

	print("TutorialPopup successfully found!")
