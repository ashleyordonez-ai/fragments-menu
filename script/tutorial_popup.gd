
extends Control

@onready var okay_button: Button = $OkayButton
@onready var welcome_text: Label = $WelcomeText
@onready var tutorial_text: Label = $TutorialText

var typing_speed: float = 0.04


func _ready() -> void:

	# Check if the tutorial was already completed
	if get_tree().root.get_meta("tutorial_completed", false):

		print("Tutorial already completed. Hiding tutorial.")

		# Hide the entire CanvasLayer
		get_parent().visible = false

		return

	# Show tutorial for first-time players
	visible = true

	okay_button.pressed.connect(_on_okay_button_pressed)

	start_typing()


func start_typing() -> void:

	# Type the welcome heading first
	welcome_text.text = "WELCOME TO THE GAME!"
	welcome_text.visible_characters = 0

	for i in range(welcome_text.text.length()):

		welcome_text.visible_characters = i + 1

		await get_tree().create_timer(typing_speed).timeout

	# Type the tutorial instructions next
	tutorial_text.text = "Use the WASD keys to move your character.

The game has 2 objects per chapter and clues are found on the dialogues.

Approach an object and click on it to interact.

Explore the map and discover what awaits you. Enjoy the game!"

	tutorial_text.visible_characters = 0

	for i in range(tutorial_text.text.length()):

		tutorial_text.visible_characters = i + 1

		await get_tree().create_timer(typing_speed).timeout


func _on_okay_button_pressed() -> void:

	# Remember that the tutorial has been completed
	get_tree().root.set_meta("tutorial_completed", true)

	print("Tutorial completed!")

	# Proceed to the next dialogue scene
	get_tree().change_scene_to_file("res://scenes/Chapter 1/Chapter 1_Time.tscn")
