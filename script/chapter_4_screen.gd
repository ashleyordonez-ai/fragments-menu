
extends Control

@onready var chapter_label: Label = $chap4
@onready var subtitle_label: Label = $Subtitle
@onready var continue_button: Button = $ContinueButton

const NEXT_SCENE := "res://scenes/Chapter 4/Chapter 4_Hospital-Scene.tscn"

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
