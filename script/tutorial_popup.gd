
extends Control

@onready var okay_button: Button = $OkayButton
@onready var tutorial_text: Label = $TutorialText

var typing_speed: float = 0.04


func _ready() -> void:

	show()

	okay_button.pressed.connect(_on_okay_button_pressed)

	start_typing()


func start_typing() -> void:

	tutorial_text.text = "WELCOME TO THE GAME!

Use the WASD keys to move your character.

Approach an object and click on it to interact.

Explore the map and discover what awaits you!"

	tutorial_text.visible_characters = 0

	for i in range(tutorial_text.text.length()):

		tutorial_text.visible_characters = i + 1

		await get_tree().create_timer(typing_speed).timeout


func _on_okay_button_pressed() -> void:

	get_tree().change_scene_to_file("res://scenes/Chapter 1/Chapter 1_Time.tscn")
