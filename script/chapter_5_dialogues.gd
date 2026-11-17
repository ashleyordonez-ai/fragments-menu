
extends Control

# =====================================
# NODE REFERENCES
# =====================================

@onready var background: TextureRect = get_node_or_null("Background") as TextureRect
@onready var dialogue_box: Node = get_node_or_null("DialogueBox")

var next_button: Button
var skip_button: Button

# =====================================
# TEXTURE REACTIONS
# =====================================

@onready var clock: TextureRect = $Clock
@onready var teddy: TextureRect = $Teddy
@onready var diary: TextureRect = $Diary
@onready var flower: TextureRect = $Flower
@onready var music_box: TextureRect = $"Music Box"

# =====================================
# KNOCKING SOUND
# =====================================

@onready var knocking_sound: AudioStreamPlayer = $KnockingSound

var is_transitioning: bool = false


# =====================================
# DIALOGUE ENTRIES
# =====================================

var dialogues = [

	{
		"character": "Leonore",
		"text": """The sun is setting; a new day is waiting,
I wonder what my tomorrow will look like?""",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Chap5_BG.png"
	},

	{
		"character": "Leonore",
		"text": """These fragments are all parts of me…
the reason why I am here today.""",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Chap5_BG.png"
	},

	{
		"character": "Leonore",
		"text": """The time when I felt lost, when I wanted to end it all.
But no… I’m still strong. And I’m willing to face
the next chapter of my life.""",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Chap5_BG.png"
	},

	{
		"character": "Leonore",
		"text": """The comfort I once clung to. You witnessed everything that
cut me so deeply. But I need to let you go for me to heal.""",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Chap5_BG.png"
	},

	{
		"character": "Leonore",
		"text": """Even with all the bad memories, there were moments that
made me happy. I genuinely appreciate those times. But everything
always comes to an end, including happiness.""",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Chap5_BG.png"
	},

	{
		"character": "Leonore",
		"text": """The beauty of these flowers has its own flaws, just like
their owner. The joy it gave me slowly turned into hatred… I don’t want
to forgive them, but I also don’t want to carry this hatred forever.""",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Chap5_BG.png"
	},

	{
		"character": "Leonore",
		"text": "This music box… I thought it was broken…",
		"expression": "",
		"position": "",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Chap5_BG.png"
	},

	{
		"character": "Leonore",
		"text": """That was exhausting, but it feels lighter now. Like something
heavy just disappeared one by one.""",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Chap5_BG.png"
	},

	{
		"character": "Teresa",
		"text": "Hi, my baby girl, how are you?",
		"expression": "glad",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Chap5_BG.png"
	},

	{
		"character": "Leonore",
		"text": "Mom… I'm sorry for–",
		"expression": "default",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Chap5_BG.png"
	},

	{
		"character": "Teresa",
		"text": """Shhhh, don't think of it, baby. All that matters now is we
are together. I'm here to help you get up again.""",
		"expression": "glad",
		"position": "left",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Chap5_BG.png"
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

	if knocking_sound == null:
		push_error("KnockingSound node could not be found!")
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

	# HIDE ALL TEXTURE REACTIONS INITIALLY

	clock.hide()
	teddy.hide()
	diary.hide()
	flower.hide()
	music_box.hide()

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

	# UPDATE TEXTURE REACTION

	update_texture_reaction()

	# DISPLAY CHARACTER AND DIALOGUE

	dialogue_box.show_dialogue(
		current["character"],
		current["text"],
		current["expression"],
		current["position"]
	)


# =====================================
# TEXTURE REACTIONS
# =====================================

func update_texture_reaction() -> void:

	# HIDE ALL TEXTURES FIRST

	clock.hide()
	teddy.hide()
	diary.hide()
	flower.hide()
	music_box.hide()

	# SHOW TEXTURE BASED ON DIALOGUE INDEX

	match dialogue_index:

		2:
			clock.show()
			print("CLOCK REACTION APPEARED")

		3:
			teddy.show()
			print("TEDDY REACTION APPEARED")

		4:
			diary.show()
			print("DIARY REACTION APPEARED")

		5:
			flower.show()
			print("FLOWER REACTION APPEARED")

		6:
			music_box.show()
			print("MUSIC BOX REACTION APPEARED")


# =====================================
# NEXT BUTTON
# =====================================

func show_next_dialogue() -> void:

	# PREVENT MULTIPLE CLICKS DURING TRANSITION

	if is_transitioning:
		return

	print("NEXT BUTTON PRESSED")

	# FIRST DIALOGUE COMPLETED

	if dialogue_index == 0:
		print("FIRST DIALOGUE COMPLETED!")

	# SECOND DIALOGUE COMPLETED

	if dialogue_index == 1:
		print("SECOND DIALOGUE COMPLETED!")

	# MOVE TO NEXT DIALOGUE

	dialogue_index += 1

	# PLAY KNOCKING SOUND ONLY BEFORE TERESA'S FIRST DIALOGUE
	# DIALOGUE INDEX 8 = TERESA'S FIRST DIALOGUE

	if dialogue_index == 8:

		print("TERESA'S FIRST DIALOGUE DETECTED")

		# PREVENT MULTIPLE CLICKS

		is_transitioning = true

		next_button.disabled = true
		skip_button.disabled = true

		# PLAY KNOCKING SOUND

		print("KNOCKING SOUND STARTED")

		knocking_sound.play()

		# WAIT UNTIL SOUND FINISHES

		await knocking_sound.finished

		# CHECK IF SCENE STILL EXISTS

		if not is_inside_tree():
			return

		print("KNOCKING SOUND FINISHED")

		# RE-ENABLE BUTTONS

		next_button.disabled = false
		skip_button.disabled = false

		is_transitioning = false

	# DISPLAY NEXT DIALOGUE

	show_current_dialogue()


# =====================================
# SKIP BUTTON
# =====================================

func skip_dialogue() -> void:

	if is_transitioning:
		return

	print("DIALOGUE SKIPPED")

	# STOP KNOCKING SOUND IF PLAYING

	if knocking_sound.playing:
		knocking_sound.stop()

	go_to_map()


# =====================================
# GO TO OUTRO
# =====================================

func go_to_map() -> void:

	print("LOADING OUTRO SCENE...")

	var next_scene := "res://scenes/outro.tscn"

	if not ResourceLoader.exists(next_scene):
		push_error("NEXT SCENE NOT FOUND: " + next_scene)
		return

	var error := get_tree().change_scene_to_file(next_scene)

	if error != OK:
		push_error("FAILED TO LOAD OUTRO SCENE: " + str(error))


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
