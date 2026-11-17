
extends Control

# =====================================
# NODE REFERENCES
# =====================================

@onready var background: TextureRect = get_node_or_null("Background") as TextureRect
@onready var dialogue_box = get_node_or_null("DialogueBox")

@onready var next_button: Button = find_child("NextButton", true, false) as Button
@onready var skip_button: Button = find_child("SkipButton", true, false) as Button


# =====================================
# TUTORIAL POPUP
# =====================================

@export var tutorial_popup_scene: PackedScene


# =====================================
# FADE OUT SETTINGS
# =====================================

const FADE_DURATION := 0.8

var transition_running: bool = false


# =====================================
# DIALOGUE ENTRIES
# =====================================

var dialogues = [

	{
		"character": "Max",
		"text": "Leonore, I really like you. Ever since I first saw you haha…",
		"expression": "smiling",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	{
		"character": "Leonore",
		"text": "Huh… why me?",
		"expression": "blush",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	{
		"character": "Max",
		"text": """I don't know, because it's you. I just like you, Leonore.
If I'm given a chance, I will court you. Can I?""",
		"expression": "smiling",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	{
		"character": "Leonore",
		"text": "To be honest, I also want us to try. Maybe we can try.",
		"expression": "blush",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	{
		"character": "Max",
		"text": "Is that a yes?",
		"expression": "blushing",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

	{
		"character": "Leonore",
		"text": "Yes, Max, it's a yes.",
		"expression": "blush",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Canteen-Dialogue BG.png"
	},

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

	print("DIALOGUE BUTTONS CONNECTED SUCCESSFULLY!")

	show_current_dialogue()


# =====================================
# DISPLAY CURRENT DIALOGUE
# =====================================

func show_current_dialogue() -> void:

	if dialogue_index >= dialogues.size():

		print("ALL DIALOGUES COMPLETED")

		show_chapter_completion_popup()
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

	change_background(background_path)

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

	show_chapter_completion_popup()


# =====================================
# SHOW CHAPTER COMPLETION POPUP
# =====================================

func show_chapter_completion_popup() -> void:

	if transition_running:
		return

	if tutorial_popup_scene == null:
		push_error("TutorialPopup scene has not been assigned in the Inspector!")
		return

	transition_running = true

	# Create an instance of the existing TutorialPopup.
	var popup := tutorial_popup_scene.instantiate()

	if popup == null:
		push_error("Could not instantiate TutorialPopup!")
		transition_running = false
		return

	# Configure the popup before adding it to the scene.
	popup.set("show_chapter_completed_on_start", true)

	popup.set(
		"chapter_completed_title",
		"Chapter 2 Completed"
	)

	popup.set(
		"chapter_completed_description",
		"""Congratulations on completing Chapter 2!

You can now proceed to the next chapter."""
	)

	# Connect the Okay button confirmation signal.
	if not popup.has_signal("chapter_completed_confirmed"):
		push_error("TutorialPopup is missing its completion signal!")
		popup.queue_free()
		transition_running = false
		return

	popup.connect(
		"chapter_completed_confirmed",
		_on_chapter_completed_confirmed
	)

	add_child(popup)

	print("CHAPTER 2 COMPLETION POPUP DISPLAYED!")


# =====================================
# CHAPTER COMPLETION CONFIRMED
# =====================================

func _on_chapter_completed_confirmed() -> void:

	print("CHAPTER 2 COMPLETION CONFIRMED!")

	await go_to_chapter_selection()


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
# GO TO CHAPTER SELECTION 3
# =====================================

func go_to_chapter_selection() -> void:

	if not transition_running:
		transition_running = true

	var next_scene := "res://scenes/Chapter Selection/ChapterSelection3.tscn"

	if not ResourceLoader.exists(next_scene):
		push_error("NEXT SCENE NOT FOUND: " + next_scene)
		return

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
