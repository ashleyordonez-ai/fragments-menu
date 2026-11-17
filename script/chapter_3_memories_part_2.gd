
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

# SOUND EFFECTS
@onready var heavy_rain_sound: AudioStreamPlayer = $HeavyRainSound
@onready var crying_sound: AudioStreamPlayer = $CryingSound


# =====================================
# DIALOGUE ENTRIES
# =====================================

var dialogues = [

	{
		"character": "Sheena",
		"text": "Leonore! Come here, I got news for you.",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	{
		"character": "Max",
		"text": "Come here, baby. Is everything alright? Did your 
		dad hurt you again? I told you, you can stay with me anytime.",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	{
		"character": "Leonore",
		"text": "Thank you, I really appreciate you guys. I'm so grateful 
		you guys are here for me.",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	{
		"character": "Leonore",
		"text": "Max? Sheena? What are you doing?",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	{
		"character": "Sheena",
		"text": "Leonore, let me explain…",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	{
		"character": "Max",
		"text": "Leonore, I'm sorry. Let's break up.",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	{
		"character": "Leonore",
		"text": "No, baby, don't— don’t leave me, please. I'm begging you…",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/BlackBG.png"
	},

	{
		"character": "Leonore",
		"text": "Is there more that I need to remember? 
		This… This is hell for me. I can't…",
		"expression": "scared",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Stairs-Dialogue BG.png"
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
	print("HeavyRainSound: ", heavy_rain_sound)
	print("CryingSound: ", crying_sound)

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

	if heavy_rain_sound == null:
		push_error("HeavyRainSound node could not be found!")
		return

	if crying_sound == null:
		push_error("CryingSound node could not be found!")
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

	# STOP SOUND EFFECTS ON THE LAST DIALOGUE
	if dialogue_index == dialogues.size() - 1:

		print("LAST DIALOGUE: STOPPING BACKGROUND SFX")

		heavy_rain_sound.stop()
		crying_sound.stop()

	# GET CURRENT DIALOGUE
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

	# HEAVY RAIN AFTER 3RD DIALOGUE
	if dialogue_index == 2:

		print("THIRD DIALOGUE COMPLETED!")

		if not heavy_rain_sound.playing:
			heavy_rain_sound.play()
			print("HEAVY RAIN SFX PLAYING!")


	# CRYING AFTER 3RD-TO-THE-LAST DIALOGUE
	if dialogue_index == dialogues.size() - 3:

		print("THIRD-TO-THE-LAST DIALOGUE COMPLETED!")

		if not crying_sound.playing:
			crying_sound.play()
			print("CRYING SFX PLAYING!")

	# MOVE TO NEXT DIALOGUE
	dialogue_index += 1

	show_current_dialogue()


# =====================================
# SKIP BUTTON
# =====================================

func skip_dialogue() -> void:

	print("DIALOGUE SKIPPED")

	go_to_map()


# =====================================
# GO TO CHAPTER 3 MEMORIES PART 2
# =====================================

func go_to_map() -> void:

	print("LOADING CHAPTER 3 MEMORIES PART 2...")

	var next_scene := "res://scenes/Chapter 3/Chapter 3_Kitchen-Scene.tscn"

	if not ResourceLoader.exists(next_scene):
		push_error("NEXT SCENE NOT FOUND: " + next_scene)
		return

	var error := get_tree().change_scene_to_file(next_scene)

	if error != OK:
		push_error("FAILED TO LOAD CHAPTER 3 MEMORIES PART 2: " + str(error))

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
