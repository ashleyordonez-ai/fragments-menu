extends Control

# =====================================
# NODE REFERENCES
# =====================================

@onready var background: TextureRect = get_node_or_null("Background") as TextureRect
@onready var dialogue_box: Node = get_node_or_null("DialogueBox")

var next_button: Button
var skip_button: Button


# =====================================
# FADE SETTINGS
# =====================================

const FADE_DURATION: float = 0.8

var transition_running: bool = false


# =====================================
# DIALOGUE ENTRIES
# =====================================

var dialogues = [

	{
		"character": "Leonore",
		"text": "I’m sorry, mom…",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Hospital.png"
	},

	{
		"character": "Leonore",
		"text": "I hate you, dad. But I hope someday…",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Hospital.png"
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

	# CHECK MAIN NODES

	if background == null:
		push_error("Background node could not be found!")
		return

	if dialogue_box == null:
		push_error("DialogueBox node could not be found!")
		return

	# FIND BUTTONS INSIDE DIALOGUE BOX

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

	# CHANGE BACKGROUND

	change_background(current["background"])

	# DISPLAY CHARACTER AND DIALOGUE

	dialogue_box.show_dialogue(
		current["character"],
		current["text"],
		current["expression"],
		current["position"]
	)


# =====================================
# NEXT BUTTON
# =====================================

func show_next_dialogue() -> void:

	if transition_running:
		return

	# MEDICINE BOTTLE SOUND AFTER FIRST DIALOGUE

	if dialogue_index == 0:

		print("FIRST DIALOGUE COMPLETED!")

	if dialogue_index == 1:

		print("SECOND DIALOGUE COMPLETED!")

	#if dialogue_index == 2:

	# MOVE TO NEXT DIALOGUE

	dialogue_index += 1

	show_current_dialogue()


# =====================================
# SKIP BUTTON
# =====================================

func skip_dialogue() -> void:

	if transition_running:
		return

	print("DIALOGUE SKIPPED")

	# STOP MEDICINE SOUND IF STILL PLAYING

	go_to_map()


# =====================================
# FADE-OUT TRANSITION
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
# GO TO CHAPTER 5 SCREEN
# =====================================

func go_to_map() -> void:

	if transition_running:
		return

	print("LOADING CHAPTER 5 SCREEN...")

	var next_scene := "res://scenes/Chapter Selection/ChapterSelection5.tscn"

	if not ResourceLoader.exists(next_scene):
		push_error("NEXT SCENE NOT FOUND: " + next_scene)
		return

	transition_running = true

	# DISABLE BUTTONS DURING TRANSITION

	if next_button != null:
		next_button.disabled = true

	if skip_button != null:
		skip_button.disabled = true

	# FADE TO BLACK

	await fade_to_black()

	# CHANGE SCENE

	var error := get_tree().change_scene_to_file(next_scene)

	if error != OK:
		push_error("FAILED TO LOAD CHAPTER 5 SCREEN: " + str(error))


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
