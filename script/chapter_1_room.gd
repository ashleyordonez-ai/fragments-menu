extends Node2D

@onready var tutorial_popup: Control = $CanvasLayer/TutorialPopup
@onready var okay_button: Button = $CanvasLayer/TutorialPopup/OkayButton

func _ready() -> void:
	tutorial_popup.show()
	okay_button.pressed.connect(_on_okay_button_pressed)

func _on_okay_button_pressed() -> void:
	tutorial_popup.hide()
