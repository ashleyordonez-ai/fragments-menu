
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

	# DIALOGUE 1 - LEONORE
	{
		"character": "Leonore",
		"text": "Didn't expect you to be this sweet, baby.",
		"expression": "blush",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	# DIALOGUE 2 - MAX
	{
		"character": "Max",
		"text": "Stop it already, Leonore. You know we already ended. 
		Sheena wanted to give this to you; she said you love these flowers.",
		"expression": "angry",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	# DIALOGUE 3 - LEONORE
	{
		"character": "Leonore",
		"text": "So why are you here if we already ended? I thought you came here to fix us?",
		"expression": "crying",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	# DIALOGUE 4 - MAX
	{
		"character": "Max",
		"text": "I'm just dropping by to check on you. I know that you're alone.",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	# DIALOGUE 5 - LEONORE
	{
		"character": "Leonore",
		"text": "Check on me? For what? You left, remember? You really want 
		to see me suffer, do you?",
		"expression": "crying",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	# DIALOGUE 6 - MAX
	{
		"character": "Max",
		"text": "If making me the bad guy helps you heal, so be it. Goodbye, Leonore.",
		"expression": "angry",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	# DIALOGUE 7 - LEONORE
	{
		"character": "Leonore",
		"text": "...",
		"expression": "crying",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	# DIALOGUE 8 - LEONORE
	{
		"character": "Leonore",
		"text": "Was that Max? What? Did he really say that? To me…? How can he…?",
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
