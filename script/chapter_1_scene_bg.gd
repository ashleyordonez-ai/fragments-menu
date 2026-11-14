
extends Control

@onready var background: TextureRect = $Background
@onready var dialogue_box = $DialogueBox

@onready var next_button: Button = dialogue_box.find_child("NextButton", true, false) as Button
@onready var skip_button: Button = dialogue_box.find_child("SkipButton", true, false) as Button


# =====================================
# DIALOGUE ENTRIES
# =====================================

var dialogues = [
	{
		"character": "Leonore",
		"text": "Hello! Welcome to our town.",
		"expression": "default",
		"position": "left",
		"background": "res://assets/backgrounds/town.png"
	},

	{
		"character": "Leonore",
		"text": "It's a beautiful day today!",
		"expression": "blush",
		"position": "left",
		"background": ""
	},

	{
		"character": "Teresa",
		"text": "Yes! I'm glad you're here.",
		"expression": "happy",
		"position": "right",
		"background": ""
	},

	{
		"character": "Leonore",
		"text": "Let's start our adventure!",
		"expression": "shy",
		"position": "left",
		"background": "res://assets/backgrounds/forest.png"
	}
]


# =====================================
# DIALOGUE INDEX
# =====================================

var dialogue_index: int = 0


# =====================================
# INITIALIZE
# =====================================

func _ready() -> void:

	print("MAIN SCENE STARTED")
	print("DialogueBox: ", dialogue_box)
	print("NextButton: ", next_button)
	print("SkipButton: ", skip_button)

	if next_button == null:
		push_error("NextButton could not be found!")
		return

	if skip_button == null:
		push_error("SkipButton could not be found!")
		return

	dialogue_box.background_changed.connect(change_background)

	next_button.pressed.connect(show_next_dialogue)
	skip_button.pressed.connect(skip_dialogue)

	# Display the first dialogue
	show_current_dialogue()


# =====================================
# DISPLAY CURRENT DIALOGUE
# =====================================

func show_current_dialogue() -> void:

	if dialogue_index >= dialogues.size():

		print("ALL DIALOGUES COMPLETED")

		next_button.disabled = true
		skip_button.disabled = true

		return

	var current = dialogues[dialogue_index]

	print("SHOWING DIALOGUE: ", current["text"])

	dialogue_box.show_dialogue(
		current["character"],
		current["text"],
		current["expression"],
		current["position"],
		current["background"]
	)


# =====================================
# NEXT BUTTON
# =====================================

func show_next_dialogue() -> void:

	dialogue_index += 1

	show_current_dialogue()


# =====================================
# SKIP BUTTON
# =====================================

func skip_dialogue() -> void:

	dialogue_index = dialogues.size()

	dialogue_box.hide()


# =====================================
# CHANGE BACKGROUND
# =====================================

func change_background(path: String) -> void:

	var texture = load(path)

	if texture:
		background.texture = texture
	else:
		print("Background not found: ", path)
