extends Control

@onready var background: TextureRect = $Background
@onready var dialogue_box = $DialogueBox

func _ready():
	dialogue_box.background_changed.connect(change_background)

	dialogue_box.call_deferred("show_dialogue")

func change_background(path: String):
	var texture = load(path)

	if texture:
		background.texture = texture
	else:
		print("Background not found: ", path)
