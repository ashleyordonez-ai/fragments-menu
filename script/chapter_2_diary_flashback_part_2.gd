
extends Control

# =====================================
# NODE REFERENCES
# =====================================

@onready var background: TextureRect = get_node_or_null("Background") as TextureRect
@onready var dialogue_box = get_node_or_null("DialogueBox")

# Search the entire scene for buttons
@onready var next_button: Button = find_child("NextButton", true, false) as Button
@onready var skip_button: Button = find_child("SkipButton", true, false) as Button


# =====================================
# FADE OUT SETTINGS
# =====================================

const FADE_DURATION := 0.8

var transition_running: bool = false


# =====================================
# DIALOGUE ENTRIES
# =====================================

var dialogues = [

	# 1. MAX
	{
		"character": "Max",
		"text": "Leonore, I really like you. Ever since I first saw you haha…",
		"expression": "smiling",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# 2. LEONORE
	{
		"character": "Leonore",
		"text": "Huh… why me?",
		"expression": "blush",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# 3. MAX
	{
		"character": "Max",
		"text": """I don't know, because it's you. I just like you, Leonore.
If I'm given a chance, I will court you. Can I?""",
		"expression": "smiling",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# 4. LEONORE
	{
		"character": "Leonore",
		"text": "To be honest, I also want us to try. Maybe we can try.",
		"expression": "blush",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# 5. MAX
	{
		"character": "Max",
		"text": "Is that a yes?",
		"expression": "blushing",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# 6. LEONORE
	{
		"character": "Leonore",
		"text": "Yes, Max, it's a yes.",
		"expression": "blush",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	# 7. LEONORE
	{
		"character": "Leonore",
		"text": """How can I forget these wonderful memories? Someone saved
me from loneliness. They made me feel so loved.""",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Attic-Dialogue BG.png"
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

	# CHECK BACKGROUND
	if background == null:
		push_error("Background node could not be found!")
		return

	# CHECK DIALOGUE BOX
	if dialogue_box == null:
		push_error("DialogueBox node could not be found!")
		return

	# CHECK NEXT BUTTON
	if next_button == null:
		push_error("NextButton could not be found! Check its node name and location.")
		return

	# CHECK SKIP BUTTON
	if skip_button == null:
		push_error("SkipButton could not be found! Check its node name and location.")
		return

	# CONNECT NEXT BUTTON
	if not next_button.pressed.is_connected(show_next_dialogue):
		next_button.pressed.connect(show_next_dialogue)

	# CONNECT SKIP BUTTON
	if not skip_button.pressed.is_connected(skip_dialogue):
		skip_button.pressed.connect(skip_dialogue)

	print("DIALOGUE BUTTONS CONNECTED SUCCESSFULLY!")

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
	var position: String = current.get("position", "left")
	var background_path: String = current.get("background", "")

	print("--------------------------------")
	print("DIALOGUE NUMBER: ", dialogue_index + 1)
	print("CHARACTER: ", character)
	print("EXPRESSION: ", expression)
	print("POSITION: ", position)

	# CHANGE BACKGROUND
	change_background(background_path)

	# DISPLAY DIALOGUE AND CHARACTER
	if dialogue_box.has_method("show_dialogue"):

		dialogue_box.show_dialogue(
			character,
			dialogue_text,
			expression,
			position,
			background_path
		)

	else:
		push_error("DialogueBox does not have a show_dialogue() function!")


# =====================================
# NEXT BUTTON
# =====================================

func show_next_dialogue() -> void:

	if transition_running:
		return

	if dialogue_index < dialogues.size():
		dialogue_index += 1

	show_current_dialogue()


# =====================================
# SKIP BUTTON
# =====================================

func skip_dialogue() -> void:

	if transition_running:
		return

	print("DIALOGUE SKIPPED")

	go_to_map()


# =====================================
# FADE OUT TO BLACK
# =====================================

func fade_to_black() -> void:

	var fade_overlay := ColorRect.new()

	fade_overlay.name = "TransitionFade"
	fade_overlay.color = Color(0, 0, 0, 0)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	fade_overlay.offset_left = 0
	fade_overlay.offset_top = 0
	fade_overlay.offset_right = 0
	fade_overlay.offset_bottom = 0

	fade_overlay.z_as_relative = false
	fade_overlay.z_index = 4096

	add_child(fade_overlay)

	var fade_tween := create_tween()

	fade_tween.tween_property(
		fade_overlay,
		"color",
		Color.BLACK,
		FADE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await fade_tween.finished


# =====================================
# GO TO CHAPTER 3
# =====================================

func go_to_map() -> void:

	if transition_running:
		return

	var next_scene := "res://scenes/Chapter Selection/ChapterSelection3.tscn"

	if not ResourceLoader.exists(next_scene):
		push_error("NEXT SCENE NOT FOUND: " + next_scene)
		return

	transition_running = true

	await fade_to_black()

	var error := get_tree().change_scene_to_file(next_scene)

	if error != OK:
		push_error("FAILED TO LOAD CHAPTER 3 SCREEN: " + str(error))


# =====================================
# CHANGE BACKGROUND
# =====================================

func change_background(path: String) -> void:

	print("CHANGING BACKGROUND: ", path)

	if path.is_empty():
		push_error("Background path is empty!")
		return

	if not ResourceLoader.exists(path):
		push_error("Background file does not exist: " + path)
		return

	var texture := load(path) as Texture2D

	if texture == null:
		push_error("Could not load background: " + path)
		return

	background.texture = texture

	print("BACKGROUND CHANGED SUCCESSFULLY!")
