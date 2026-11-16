
extends Control

@onready var background: TextureRect = $Background
@onready var dialogue_box = $DialogueBox

@onready var next_button: Button = dialogue_box.find_child(
	"NextButton", true, false
) as Button

@onready var skip_button: Button = dialogue_box.find_child(
	"SkipButton", true, false
) as Button


# =====================================
# DIALOGUE ENTRIES
# =====================================

var dialogues = [

	# DIALOGUE 1
	{
		"character": "Leonore",
		"text": "God, if you're listening, can you please tell me why I need to suffer?
What did I do to deserve this?",
		"expression": "crying",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - NIGHT (Dialogue BG).png"
	},

	# DIALOGUE 2
	{
		"character": "Leonore",
		"text": "I can't bear this pain anymore. You know that I have no one to run to;
why do they need to do these things to me? I really don't know
how to hold on anymore.",
		"expression": "crying",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - NIGHT (Dialogue BG).png"
	},

	# DIALOGUE 3 - UNKNOWN SPEAKER
	{
		"character": "",
		"text": "Leonore!!!",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	# DIALOGUE 4
	{
		"character": "Leonore",
		"text": "Huh? Someone is calling my name.",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	# DIALOGUE 5 - UNKNOWN SPEAKER
	{
		"character": "",
		"text": "Leonore, please, hold on. I'm begging you.",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	# DIALOGUE 6
	{
		"character": "Leonore",
		"text": "Was that Mom? I miss her so much.",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
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
	print("Background: ", background)
	print("DialogueBox: ", dialogue_box)
	print("NextButton: ", next_button)
	print("SkipButton: ", skip_button)

	if background == null:
		push_error("Background node could not be found!")
		return

	if dialogue_box == null:
		push_error("DialogueBox node could not be found!")
		return

	if next_button == null:
		push_error("NextButton could not be found!")
		return

	if skip_button == null:
		push_error("SkipButton could not be found!")
		return

	if not next_button.pressed.is_connected(show_next_dialogue):
		next_button.pressed.connect(show_next_dialogue)

	if not skip_button.pressed.is_connected(skip_dialogue):
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

	var character: String = current.get("character", "")
	var dialogue_text: String = current.get("text", "")
	var expression: String = current.get("expression", "")
	var position: String = current.get("position", "")
	var background_path: String = current.get("background", "")

	print("SHOWING DIALOGUE: ", dialogue_text)
	print("CHARACTER: ", character if character != "" else "HIDDEN / UNKNOWN")

	# CHANGE BACKGROUND
	change_background(background_path)

	# DISPLAY DIALOGUE
	# Empty character names are intentionally preserved.
	dialogue_box.show_dialogue(
		character,
		dialogue_text,
		expression,
		position,
		background_path
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

	get_tree().root.set_meta("current_tutorial", "game play")

	get_tree().change_scene_to_file(
		"res://scenes/Maps/Chapter 1_Room.tscn"
	)


# =====================================
# CHANGE BACKGROUND
# =====================================

func change_background(path: String) -> void:

	print("CHANGING BACKGROUND: ", path)

	if not ResourceLoader.exists(path):
		push_error("Background file does not exist: " + path)
		return

	var texture = load(path) as Texture2D

	if texture == null:
		push_error("Could not load background: " + path)
		return

	background.texture = texture

	print("BACKGROUND CHANGED SUCCESSFULLY!")
