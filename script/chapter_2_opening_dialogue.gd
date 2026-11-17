
extends Control

@onready var background: TextureRect = $Background
@onready var dialogue_box = $DialogueBox

@onready var next_button: Button = dialogue_box.find_child("NextButton", true, false) as Button
@onready var skip_button: Button = dialogue_box.find_child("SkipButton", true, false) as Button


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
		"text": "I wonder what’s in here.",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Attic-Dialogue BG.png"
	},
	
	{
		"character": "Leonore",
		"text": "Oh, a teddy bear!",
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
	print("DialogueBox: ", dialogue_box)
	print("NextButton: ", next_button)
	print("SkipButton: ", skip_button)

	if next_button == null:
		push_error("NextButton could not be found!")
		return

	if skip_button == null:
		push_error("SkipButton could not be found!")
		return

	next_button.pressed.connect(show_next_dialogue)
	skip_button.pressed.connect(skip_dialogue)

	# Display the first dialogue
	show_current_dialogue()

	# Fade in after dialogue is initialized.
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

	get_tree().change_scene_to_file(
		"res://scenes/Maps/Chapter 2_Attic.tscn"
	)


# =====================================
# CHANGE BACKGROUND
# =====================================

func change_background(path: String) -> void:

	var texture = load(path)

	if texture:
		background.texture = texture
	else:
		print("Background not found: ", path)
