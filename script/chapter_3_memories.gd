
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

# BEATING SOUND EFFECT
@onready var beating_sound: AudioStreamPlayer = $BeatingSound


# =====================================
# DIALOGUE ENTRIES
# =====================================

var dialogues = [

	{
		"character": "Arthur",
		"text": "I miss your mom. Why am I so far away from her?",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	{
		"character": "Arthur",
		"text": "I miss Mom too dad.",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	{
		"character": "Arthur",
		"text": "STOP CALLING ME DAD! I AM NOT YOUR FATHER!!",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	{
		"character": "",
		"text": "STOP CALLING ME DAD! I AM NOT YOUR FATHER!!",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
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
	print("BeatingSound: ", beating_sound)

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

	if beating_sound == null:
		push_error("BeatingSound node could not be found!")
		return

	# CONNECT NEXT BUTTON
	if not next_button.pressed.is_connected(show_next_dialogue):
		next_button.pressed.connect(show_next_dialogue)

	# CONNECT SKIP BUTTON
	if not skip_button.pressed.is_connected(skip_dialogue):
		skip_button.pressed.connect(skip_dialogue)

	print("DIALOGUE BUTTONS CONNECTED SUCCESSFULLY!")

	# DISPLAY FIRST DIALOGUE
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

	# CHANGE BACKGROUND FIRST
	change_background(current["background"])

	# DISPLAY CHARACTER AND DIALOGUE
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

	# PLAY BEATING SOUND AFTER SECOND-TO-LAST DIALOGUE
	if dialogue_index == dialogues.size() - 2:

		print("SECOND-TO-LAST DIALOGUE COMPLETED!")

		if not beating_sound.playing:
			beating_sound.play()
			print("BEATING SOUND PLAYING!")

	dialogue_index += 1

	show_current_dialogue()


# =====================================
# SKIP BUTTON
# =====================================

func skip_dialogue() -> void:

	print("DIALOGUE SKIPPED")

	go_to_map()


# =====================================
# GO TO CHAPTER 3 STAIRS
# =====================================

func go_to_map() -> void:

	print("LOADING CHAPTER 3 STAIRS...")

	var next_scene := "res://scenes/Chapter 3/Chapter 3_Memories-Part 2.tscn"

	if not ResourceLoader.exists(next_scene):
		push_error("NEXT SCENE NOT FOUND: " + next_scene)
		return

	var error := get_tree().change_scene_to_file(next_scene)

	if error != OK:
		push_error("FAILED TO LOAD CHAPTER 3 STAIRS: " + str(error))


# =====================================
# CHANGE BACKGROUND
# =====================================

func change_background(path: String) -> void:

	print("CHANGING BACKGROUND: ", path)

	if not ResourceLoader.exists(path):
		push_error("BACKGROUND FILE NOT FOUND: " + path)
		return

	var texture := load(path) as Texture2D

	if texture == null:
		push_error("FAILED TO LOAD BACKGROUND TEXTURE: " + path)
		return

	background.texture = texture

	background.show()

	print("BACKGROUND LOADED SUCCESSFULLY!")
	print("BACKGROUND TEXTURE: ", background.texture)
