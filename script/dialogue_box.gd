
extends Control

signal background_changed(path: String)

@onready var dialogue_text = $Background/DialogueText
@onready var name_label = $Background/NameLabel

@onready var left_portrait = $CharacterPortraitLeft
@onready var right_portrait = $CharacterPortraitRight


func _ready() -> void:
	right_portrait.hide()



func show_dialogue(
	character_name: String,
	dialogue: String,
	expression: String = "default",
	position: String = "left",
	background_path: String = ""
) -> void:

	print("SHOW_DIALOGUE CALLED")
	print("Character: ", character_name)
	print("Dialogue: ", dialogue)

	name_label.text = character_name
	dialogue_text.text = dialogue

	if position == "left":
		left_portrait.show_character(
			character_name,
			expression + "-left"
		)

		right_portrait.hide()

	elif position == "right":
		right_portrait.show_character(
			character_name,
			expression + "-right"
		)

		left_portrait.hide()

	if background_path != "":
		background_changed.emit(background_path)


func show_two_characters(
	left_name: String,
	left_expression: String,
	right_name: String,
	right_expression: String
) -> void:

	left_portrait.show_character(left_name, left_expression)
	right_portrait.show_character(right_name, right_expression)
