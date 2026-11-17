
extends Control

# =====================================
# NODE REFERENCES
# =====================================

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
		"text": "Dear diary, I'm really, really glad someone approached me. Her 
		name is Sheena. She said that I looked lonely so she wanted to be 
		with me. She also had a friend named Max with her earlier. 
		He was really shy…",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	# DIALOGUE 2 - LEONORE
	{
		"character": "Leonore",
		"text": "Hi diary. Today, Sheena and I went to the school 
		cafeteria together. We ate and talked about A LOT of things. 
		I feel so light when I'm with her, she's my twin! I really enjoyed 
		her company, I hope we can be friends forever. I'm so happy with her!",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	# DIALOGUE 3 - SHEENA
	{
		"character": "Sheena",
		"text": "Leonore! Come here, let's go and eat our lunch!",
		"expression": "happy",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# DIALOGUE 4 - MAX
	{
		"character": "Max",
		"text": "H-hey, Leonore… I'm Max. Um… I guess I'll be joining 
		you for lunch today. Hehe…",
		"expression": "smiling",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# DIALOGUE 5 - SHEENA
	{
		"character": "Sheena",
		"text": "Leonore, I'm sorry, but something urgent came up. 
		Max will stay here and keep you company, okay? I have to go now. Bye!",
		"expression": "smiling",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# DIALOGUE 6 - MAX
	{
		"character": "Max",
		"text": "So do you have plans after class?",
		"expression": "blushing",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# DIALOGUE 7 - LEONORE
	{
		"character": "Leonore",
		"text": "Uhh, yes, the usual. Lock myself in my bedroom, read, 
		do my assignments, sleep, repeat.",
		"expression": "shy",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# DIALOGUE 8 - MAX
	{
		"character": "Max",
		"text": "Aw, you don't have to do that anymore. I'm– I mean we're 
		here to add some thrill to your life. Just call us whenever 
		you want to go out.",
		"expression": "smiling",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# DIALOGUE 9 - LEONORE
	{
		"character": "Leonore",
		"text": "Are you sure?",
		"expression": "shy",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# DIALOGUE 10 - MAX
	{
		"character": "Max",
		"text": "Yup. I really want to spend more time with you, you know.",
		"expression": "blushing",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
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
	var position: String = "left"
	var background_path: String = current.get("background", "")

	print("--------------------------------")
	print("DIALOGUE NUMBER: ", dialogue_index + 1)
	print("CHARACTER: ", character)
	print("EXPRESSION: ", expression)
	print("POSITION: ", position)

	# CHANGE BACKGROUND
	change_background(background_path)

	# DISPLAY DIALOGUE AND CHARACTER
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
# GO TO NEXT SCENE
# =====================================

func go_to_map() -> void:

	get_tree().change_scene_to_file(
		"res://scenes/Chapter 2/Chapter 2_Diary-Flashback-Part 2.tscn"
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
