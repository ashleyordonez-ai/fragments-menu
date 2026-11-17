
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
		"text": "Dear diary, I'm really, really glad someone approached me. 
		Her name is Sheena. She said that I looked lonely so she wanted to be 
		with me. She also had a friend named Max with her earlier. 
		He was really shy…",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	{
		"character": "Leonore",
		"text": "Hi diary. Today, Sheena and I went to the school cafeteria 
		together. We ate and talked about A LOT of things. I feel so light when 
		I'm with her, she's my twin! I really enjoyed her company, I hope we 
		can be friends forever. I'm so happy with her!",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},
	
	{
		"character": "Arthur",
		"text": "Shut up! If it weren't for you, Teresa would be here beside me! 
		We would be happy, just the two of us. ",
		"expression": "angry",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Living Room.png"
	},
	
	{
		"character": "Leonore",
		"text": "Please don't leave me… Dad… Please.",
		"expression": "crying",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Living Room.png"
	},
	
	{
		"character": "Leonore",
		"text": "Huh? What was that?",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Attic-Dialogue BG.png"
	},
	
	{
		"character": "Leonore",
		"text": "Nevermind. I'll just explore this room more.",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Attic-Dialogue BG.png"
	},

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

	get_tree().change_scene_to_file(
		"res://scenes/Maps/Chapter 2_Attic.tscn"
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
