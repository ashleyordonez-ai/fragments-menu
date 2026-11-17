
extends Control

@onready var portrait: TextureRect = get_node_or_null("Portrait") as TextureRect


# =====================================
# CHARACTER IMAGE DATABASE
# =====================================

var character_images = {

	"Leonore": {
		"default-left": "res://assets/sprites/characters/Leonore/Leonore-Left_Default.png",
		"default-right": "res://assets/sprites/characters/Leonore/Leonore-Right_Default.png",

		"blush-left": "res://assets/sprites/characters/Leonore/Leonore-Left_Blush.png",
		"blush-right": "res://assets/sprites/characters/Leonore/Leonore-Right_Blush.png",

		"crying-left": "res://assets/sprites/characters/Leonore/Leonore-Left_Crying.png",
		"crying-right": "res://assets/sprites/characters/Leonore/Leonore-Right_Crying.png",

		"scared-left": "res://assets/sprites/characters/Leonore/Leonore-Left_Scared.png",
		"scared-right": "res://assets/sprites/characters/Leonore/Leonore-Right_Scared.png",

		"shy-left": "res://assets/sprites/characters/Leonore/Leonore-Left_Shy.png",
		"shy-right": "res://assets/sprites/characters/Leonore/Leonore-Right_Shy.png",
	},

	"Teresa": {
		"default-left": "res://assets/sprites/characters/Teresa/Teresa-Left_Default.png",
		"default-right": "res://assets/sprites/characters/Teresa/Teresa-Right_Default.png",

		"angry-left": "res://assets/sprites/characters/Teresa/Teresa-Left_Angry.png",
		"angry-right": "res://assets/sprites/characters/Teresa/Teresa-Right_Angry.png",

		"crying-left": "res://assets/sprites/characters/Teresa/Teresa-Left_Crying.png",
		"crying-right": "res://assets/sprites/characters/Teresa/Teresa-Right_Crying.png",

		"glad-left": "res://assets/sprites/characters/Teresa/Teresa-Left_Glad.png",
		"glad-right": "res://assets/sprites/characters/Teresa/Teresa-Right_Glad.png",

		"happy-left": "res://assets/sprites/characters/Teresa/Teresa-Left_Happy.png",
		"happy-right": "res://assets/sprites/characters/Teresa/Teresa-Right_Happy.png",

		"talking-left": "res://assets/sprites/characters/Teresa/Teresa-Left_Talking.png",
		"talking-right": "res://assets/sprites/characters/Teresa/Teresa-Right_Talking.png"
	},

	"Max": {
		"default-left": "res://assets/sprites/characters/Max/Max-Left_Defult.png",
		"default-right": "res://assets/sprites/characters/Max/Max-Right_Defult.png",

		"angry-left": "res://assets/sprites/characters/Max/Max-Left_Angry.png",
		"angry-right": "res://assets/sprites/characters/Max/Max-RightAngry.png",

		"blushing-left": "res://assets/sprites/characters/Max/Max-Left_Blushing.png",
		"blushing-right": "res://assets/sprites/characters/Max/Max-RightBlushing.png",

		"crying-left": "res://assets/sprites/characters/Max/Max-Left_Crying.png",
		"crying-right": "res://assets/sprites/characters/Max/Max-Right_Crying.png",

		"smiling-left": "res://assets/sprites/characters/Max/Max-Left_Smiling.png",
		"smiling-right": "res://assets/sprites/characters/Max/Max-Right_Smiling.png",

		"surprised-left": "res://assets/sprites/characters/Max/Max-Left_Surprised.png",
		"surprised-right": "res://assets/sprites/characters/Max/Max-Right_Surprised.png",

		"yawning-left": "res://assets/sprites/characters/Max/Max-Left_Yawning.png",
		"yawning-right": "res://assets/sprites/characters/Max/Max-Right_Yawning.png",
	},

	"Arthur": {
		"default-left": "res://assets/sprites/characters/Arthur/Arthur-Left_Default.png",
		"default-right": "res://assets/sprites/characters/Arthur/Arthur-Right_Default.png",

		"angry-left": "res://assets/sprites/characters/Arthur/Arthur-Left_Angry.png",
		"angry-right": "res://assets/sprites/characters/Arthur/Arthur-Right_Angry.png",

		"crying-left": "res://assets/sprites/characters/Arthur/Arthur-Left_Crying.png",
		"crying-right": "res://assets/sprites/characters/Arthur/Arthur-Right_Crying.png",

		"huh-left": "res://assets/sprites/characters/Arthur/Arthur-Left_Huh.png",
		"huh-right": "res://assets/sprites/characters/Arthur/Arthur-Right_Huh.png",

		"tired-left": "res://assets/sprites/characters/Arthur/Arthur-Left_Tired.png",
		"tired-right": "res://assets/sprites/characters/Arthur/Arthur-Right_Tired.png",
	},

	"Sheena": {
		"default-left": "res://assets/sprites/characters/Sheena/Sheena-Left_Default.png",
		"default-right": "res://assets/sprites/characters/Sheena/Sheena-Right_Default.png",

		"blush-left": "res://assets/sprites/characters/Sheena/Sheena-Left_Blush.png",
		"blush-right": "res://assets/sprites/characters/Sheena/Sheena-Right_Blush.png",

		"crying-left": "res://assets/sprites/characters/Sheena/Sheena-Left_Crying.png",
		"crying-right": "res://assets/sprites/characters/Sheena/Sheena-Right_Crying.png",

		"happy_blush-left": "res://assets/sprites/characters/Sheena/Sheena-Left_Happy-Blush.png",
		"happy_blush-right": "res://assets/sprites/characters/Sheena/Sheena-Right_Happy-Blush.png",

		"happy-left": "res://assets/sprites/characters/Sheena/Sheena-Left_Happy.png",
		"happy-right": "res://assets/sprites/characters/Sheena/Sheena-Right_Happy.png",

		"shocked-left": "res://assets/sprites/characters/Sheena/Sheena-Left_Shocked.png",
		"shocked-right": "res://assets/sprites/characters/Sheena/Sheena-Right_Shocked.png",
	}
}


# =====================================
# SHOW CHARACTER
# =====================================

func show_character(
	character_name: String,
	expression: String = "default-left"
) -> void:

	print("SHOWING CHARACTER: ", character_name)
	print("EXPRESSION: ", expression)

	if portrait == null:
		push_error("Portrait TextureRect node could not be found!")
		return

	# Check character
	if not character_images.has(character_name):
		push_warning("Character not found: " + character_name)
		hide_character()
		return

	var expressions = character_images[character_name]

	# Check expression
	if not expressions.has(expression):
		push_warning(
			"Expression not found: " + character_name + " - " + expression
		)
		hide_character()
		return

	var image_path: String = expressions[expression]

	# Check image file
	if not ResourceLoader.exists(image_path):
		push_error("Character image does not exist: " + image_path)
		hide_character()
		return

	var texture = load(image_path) as Texture2D

	if texture == null:
		push_error("Could not load character image: " + image_path)
		hide_character()
		return

	# Assign image
	portrait.texture = texture

	portrait.show()
	show()

	print("CHARACTER IMAGE LOADED SUCCESSFULLY: ", image_path)


# =====================================
# HIDE CHARACTER
# =====================================

func hide_character() -> void:

	hide()
