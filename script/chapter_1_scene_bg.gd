
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
		"text": "Huh? Where am I?",
		"expression": "default",
		"position": "left",
		"background": "res://assets/illustrations/Dialogue Backrgounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	{
		"character": "Leonore",
		"text": "Why am I here?",
		"expression": "default",
		"position": "left",
		"background": "res://assets/illustrations/Dialogue Backrgounds/Leonore's Room - DAY (Dialogue BG).png"
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

	if dialogue_box == null:
		push_error("DialogueBox could not be found!")
		return

	if next_button == null:
		push_error("NextButton could not be found!")
		return

	if skip_button == null:
		push_error("SkipButton could not be found!")
		return

	next_button.pressed.connect(show_next_dialogue)
	skip_button.pressed.connect(skip_dialogue)

	show_current_dialogue()


# =====================================
# DISPLAY CURRENT DIALOGUE
# =====================================

func show_current_dialogue() -> void:

	if dialogue_index >= dialogues.size():

		print("ALL DIALOGUES COMPLETED")

		go_to_map()
		return

	var current = dialogues[dialogue_index]

	print("SHOWING DIALOGUE: ", current["text"])

	# Change background directly
	change_background(current["background"])

	# Display character portrait and dialogue
	dialogue_box.show_dialogue(
		current["character"],
		current["text"],
		current["expression"],
		current["position"]
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

	print("DIALOGUE SKIPPED")

	go_to_map()


# =====================================
# GO TO MAP SCENE
# =====================================

func go_to_map() -> void:

	get_tree().change_scene_to_file(
		"res://scenes/Maps/Chapter 1_Room.tscn"
	)


# =====================================
# CHANGE BACKGROUND
# =====================================

func change_background(path: String) -> void:

	if path.is_empty():
		return

	var texture = load(path) as Texture2D

	if texture:
		background.texture = texture
	else:
		push_error("Background not found: " + path)
