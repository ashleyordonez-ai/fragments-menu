
extends Control

signal background_changed(path: String)

@onready var name_label: Label = $Background/NameLabel
@onready var dialogue_text: Label = $Background/DialogueText
@onready var next_button: Button = $Background/NextButton
@onready var portrait: TextureRect = $CharacterPortrait/Portrait
@onready var skip_button: Button = $Background/SkipButton

var dialogues = [
	{
		"speaker": "Leonore",
		"text": "Huh? Where am I?",
		"expression": "Leonore-Left_Default.png",
		"background": "res://assets/Illustrations/Dialogue Backgrounds/Leonore's Room - DAY (Dialogue BG).png"
	},
	{
		"speaker": "Leonore",
		"text": "Why am I here?",
		"expression": "Leonore-Left_Default.png"
	}
]

var current_dialogue = 0

func _ready():
	next_button.pressed.connect(_on_next_button_pressed)
	skip_button.pressed.connect(_on_skip_button_pressed)
	show_dialogue()

func show_dialogue():
	if current_dialogue >= dialogues.size():
		hide()
		return

	var dialogue = dialogues[current_dialogue]

	name_label.text = dialogue["speaker"]
	dialogue_text.text = dialogue["text"]

	if dialogue.has("character") and dialogue.has("expression"):
		show_character(dialogue["character"], dialogue["expression"])

	var background_path = dialogue.get("background", "")

	if background_path != "":
		background_changed.emit(background_path)
	
func show_character(character: String, expression: String):
	
	var path = "res://assets/sprites/characters/" + character + "/" + expression
	
	var texture = load(path)

	if texture:
		portrait.texture = texture
		portrait.visible = true
	else:
		print("Portrait not found: ", path)

func _on_next_button_pressed():
	current_dialogue += 1
	show_dialogue()
	
func _on_skip_button_pressed():
	current_dialogue = dialogues.size()
	show_dialogue()
