
extends Control

@onready var dialogue_text: Label = $Background/DialogueText
@onready var name_label: Label = $Background/NameLabel

@onready var left_portrait = $CharacterPortraitLeft
@onready var right_portrait = $CharacterPortraitRight


func _ready() -> void:
	right_portrait.hide_character()
	left_portrait.hide_character()


# =====================================
# DISPLAY DIALOGUE
# =====================================

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

		right_portrait.hide_character()
		left_portrait.show()

	elif position == "right":
		right_portrait.show_character(
			character_name,
			expression + "-right"
		)

		left_portrait.hide_character()
		right_portrait.show()

	else:
		left_portrait.hide_character()
		right_portrait.hide()

	print("SHOW_DIALOGUE CALLED")
	print("Character: ", character_name)
	print("Expression: ", expression)
	print("Position: ", position)
	print("Dialogue: ", dialogue)

	name_label.text = character_name
	dialogue_text.text = dialogue

	# =====================================
	# DISPLAY CHARACTER EXPRESSION
	# =====================================

	if character_name != "" and expression != "":

		if position == "left":

			left_portrait.show_character(
				character_name,
				expression + "-left"
			)

			right_portrait.hide_character()

		elif position == "right":

			right_portrait.show_character(
				character_name,
				expression + "-right"
			)

			left_portrait.hide_character()

		else:
			left_portrait.hide_character()
			right_portrait.hide_character()

	else:
		# Hide both portraits for narration
		# or dialogue from an off-screen character.

		left_portrait.hide_character()
		right_portrait.hide_character()

	# =====================================
	# BACKGROUND
	# =====================================

	if background_path != "":
		print("BACKGROUND PATH RECEIVED: ", background_path)


# =====================================
# DISPLAY TWO CHARACTERS
# =====================================

func show_two_characters(
	left_name: String,
	left_expression: String,
	right_name: String,
	right_expression: String
) -> void:

	left_portrait.show_character(left_name, left_expression)
	right_portrait.show_character(right_name, right_expression)
