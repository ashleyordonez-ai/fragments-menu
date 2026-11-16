
extends Control

@onready var title_label: Label = get_node_or_null("Title") as Label
@onready var description_label: Label = get_node_or_null("Description") as Label
@onready var okay_button: Button = get_node_or_null("OkayButton") as Button


func _ready() -> void:
	hide()

	# Check required nodes
	if title_label == null:
		push_error("Title Label not found!")
		return

	if description_label == null:
		push_error("Description Label not found!")
		return

	if okay_button == null:
		push_error("OkayButton not found!")
		return

	# Connect Okay button
	if not okay_button.pressed.is_connected(hide_tutorial):
		okay_button.pressed.connect(hide_tutorial)

	# Get selected tutorial
	var tutorial_id = get_tree().root.get_meta(
		"current_tutorial",
		""
	)

	print("CURRENT TUTORIAL: ", tutorial_id)

	# Display the appropriate tutorial
	match tutorial_id:

		"movement":
			show_tutorial(
				"Movement Tutorial",
				"Use the WASD keys to move your character around."
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

		_:
			hide_tutorial()

	# Clear tutorial ID
	if get_tree().root.has_meta("current_tutorial"):
		get_tree().root.remove_meta("current_tutorial")


func show_tutorial(title: String, description: String) -> void:
	title_label.text = title
	description_label.text = description
	show()


func hide_tutorial() -> void:
	hide()
