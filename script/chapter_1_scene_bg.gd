
extends Control

# =====================================
# NODE REFERENCES
# =====================================

@onready var background = get_node_or_null("Background")
@onready var dialogue_box = get_node_or_null("DialogueBox")

var next_button: Button
var skip_button: Button


# =====================================
# FADE IN SETTINGS
# =====================================

const FADE_DURATION := 1.1


# =====================================
# DIALOGUE ENTRIES
# =====================================

var dialogues = [

	{
		"character": "Leonore",
		"text": "Huh? Where am I?",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},

	{
		"character": "Leonore",
		"text": "Why am I here?",
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

	if background == null:
		push_error("Background node could not be found!")
		return

	if dialogue_box == null:
		push_error("DialogueBox could not be found!")
		return

	# Find buttons safely
	next_button = dialogue_box.find_child(
		"NextButton", true, false
	) as Button

	skip_button = dialogue_box.find_child(
		"SkipButton", true, false
	) as Button

	if next_button == null:
		push_error("NextButton could not be found!")
		return

	if skip_button == null:
		push_error("SkipButton could not be found!")
		return

	# Connect buttons
	if not next_button.pressed.is_connected(show_next_dialogue):
		next_button.pressed.connect(show_next_dialogue)

	if not skip_button.pressed.is_connected(skip_dialogue):
		skip_button.pressed.connect(skip_dialogue)

	print("BACKGROUND FOUND: ", background)
	print("DIALOGUE BOX FOUND: ", dialogue_box)

	show_current_dialogue()

	# Fade in after the dialogue is initialized.
	await fade_from_black()


# =====================================
# FADE IN FROM BLACK
# =====================================

func fade_from_black() -> void:

	var fade_overlay := ColorRect.new()

	fade_overlay.name = "TransitionFade"
	fade_overlay.color = Color.BLACK
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
		"color:a",
		0.0,
		FADE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await fade_tween.finished

	fade_overlay.queue_free()


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

	# CHANGE BACKGROUND
	change_background(background_path)

	# DISPLAY CHARACTER AND DIALOGUE
	# Keep the original FOUR arguments.
	dialogue_box.show_dialogue(
		character,
		dialogue_text,
		expression,
		position
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

	print("GOING TO MAP")

	get_tree().root.set_meta("current_tutorial", "movement")

	print(
		"TUTORIAL ID SET: ",
		get_tree().root.get_meta("current_tutorial", "")
	)

	get_tree().change_scene_to_file(
		"res://scenes/Maps/Chapter 1_Room.tscn"
	)


# =====================================
# CHANGE BACKGROUND
# =====================================

func change_background(path: String) -> void:

	if path.is_empty():
		push_warning("Background path is empty!")
		return

	if background == null:
		push_error("Background node is missing!")
		return

	if not ResourceLoader.exists(path):
		push_error("Background file does not exist: " + path)
		return

	var texture := load(path) as Texture2D

	if texture == null:
		push_error("Could not load background: " + path)
		return

	if background is TextureRect or background is Sprite2D:

		background.texture = texture

	else:

		push_error(
			"Unsupported Background node type: "
			+ background.get_class()
		)
		return

	print("BACKGROUND CHANGED SUCCESSFULLY!")
