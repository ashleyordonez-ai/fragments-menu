
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
		"text": "I wonder what time it is.",
		"expression": "default-left",
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

		go_to_map()

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

	print("DIALOGUE SKIPPED")

	go_to_map()


# =====================================
# GO TO MAP SCENE
# =====================================

func go_to_map() -> void:
	get_tree().root.set_meta("chapter1_dialogue_completed", true)

	print("CHAPTER 1 DIALOGUE COMPLETED!")

	get_tree().change_scene_to_file("res://scenes/Maps/Chapter 1_Room.tscn")


# =====================================
# CHANGE BACKGROUND
# =====================================

func change_background(path: String) -> void:

	var texture = load(path)

	if texture:
		background.texture = texture
	else:
		print("Background not found: ", path)
