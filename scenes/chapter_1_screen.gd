
extends Control

@onready var chapter_label: Label = $chap1
@onready var subtitle_label: Label = $subtitle
@onready var continue_button: Button = $ContinueButton

const NEXT_SCENE := "res://scenes/Chapter 1/Chapter 1_SceneBG.tscn"

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)

func _on_continue_pressed() -> void:
	print("CONTINUE BUTTON PRESSED!")

	if not ResourceLoader.exists(NEXT_SCENE):
		push_error("SCENE NOT FOUND: " + NEXT_SCENE)
		return

	var error := get_tree().change_scene_to_file(NEXT_SCENE)

	if error != OK:
		push_error("FAILED TO LOAD NEXT SCENE. ERROR: " + str(error))
