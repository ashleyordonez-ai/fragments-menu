
extends Control

# =====================================
# NODE REFERENCES
# =====================================

@onready var title_label: Label = get_node_or_null("WelcomeText") as Label
@onready var description_label: Label = get_node_or_null("TutorialText") as Label
@onready var okay_button: Button = get_node_or_null("OkayButton") as Button


# =====================================
# NEXT SCENES
# =====================================

@export var movement_next_scene: PackedScene
@export var chapter_completed_next_scene: PackedScene


# =====================================
# TYPING ANIMATION SETTINGS
# =====================================

@export var typing_speed: float = 0.035

var current_tutorial_id: String = ""
var typing_finished: bool = false
var is_transitioning: bool = false


# =====================================
# INITIALIZE
# =====================================

func _ready() -> void:

	hide()

	if title_label == null:
		push_error("WelcomeText Label not found!")
		return

	if description_label == null:
		push_error("TutorialText Label not found!")
		return

	if okay_button == null:
		push_error("OkayButton not found!")
		return

	if not okay_button.pressed.is_connected(_on_okay_button_pressed):
		okay_button.pressed.connect(_on_okay_button_pressed)

	current_tutorial_id = get_tree().root.get_meta(
		"current_tutorial",
		""
	)

	print("CURRENT TUTORIAL: ", current_tutorial_id)

	match current_tutorial_id:

		"movement":
			show_tutorial(
				"Movement Tutorial",
				"Use the WASD keys to move your character around.

Walk around the map and find the fragments to unlock the story.

Clues for interactable objects are on the dialogues.

Enjoy the game!"
			)

		"interaction":
			show_tutorial(
				"Interaction Tutorial",
				"Approach an object and click on it to interact."
			)

		"inspection":
			show_tutorial(
				"Inspection Tutorial",
				"Click on objects to discover more about them."
			)

		"game play":
			show_tutorial(
				"Game Play Tutorial",
				"In each of the chapter, there are 2 objects that you need to find.

Proceed to the next fragment to unlock another part of the story."
			)

		"chapter completed":
			show_tutorial(
				"Chapter 1 Completed",
				"Congratulations on completing chapter 1!

You can now proceed to the next chapter."
			)

		_:
			hide_tutorial()

	if get_tree().root.has_meta("current_tutorial"):
		get_tree().root.remove_meta("current_tutorial")


# =====================================
# SHOW TUTORIAL
# =====================================

func show_tutorial(title: String, description: String) -> void:

	title_label.text = title

	show()

	type_description(description)


# =====================================
# TYPING ANIMATION
# =====================================

func type_description(description: String) -> void:

	typing_finished = false

	description_label.text = description
	description_label.visible_characters = 0

	for i in range(description.length()):

		description_label.visible_characters = i + 1

		await get_tree().create_timer(typing_speed).timeout

		if not is_visible_in_tree():
			return

	description_label.visible_characters = -1
	typing_finished = true


# =====================================
# OKAY BUTTON
# =====================================

func _on_okay_button_pressed() -> void:

	if is_transitioning:
		return

	print("TUTORIAL COMPLETED: ", current_tutorial_id)

	match current_tutorial_id:

		"movement":
			load_next_scene(movement_next_scene)

		"interaction":
			hide_tutorial()

		"inspection":
			hide_tutorial()

		"game play":
			hide_tutorial()

		"chapter completed":
			load_next_scene(chapter_completed_next_scene)


# =====================================
# LOAD NEXT SCENE
# =====================================

func load_next_scene(scene: PackedScene) -> void:

	print("ATTEMPTING TO LOAD NEXT SCENE...")

	if scene == null:
		push_error("Next Scene has not been assigned!")
		return

	print("SCENE TO LOAD: ", scene.resource_path)

	is_transitioning = true
	okay_button.disabled = true

	var error = get_tree().change_scene_to_packed(scene)

	print("SCENE CHANGE RESULT: ", error)

	if error != OK:

		push_error("Failed to load the next scene!")

		is_transitioning = false
		okay_button.disabled = false


# =====================================
# HIDE TUTORIAL
# =====================================

func hide_tutorial() -> void:

	hide()
