extends Node2D

@onready var tutorial_panel = $CanvasLayer/TutorialPanel

func _ready() -> void:
	tutorial_panel.show()

func _on_start_button_pressed() -> void:
	tutorial_panel.hide()
