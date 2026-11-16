
extends Control

@export var title_delay: float = 0.25
@export var title_duration: float = 0.6
@export var heading_delay: float = 0.2
@export var heading_duration: float = 0.4
@export var button_delay: float = 0.15
@export var button_duration: float = 0.4
@export var slide_distance: float = 10.0

@export var hover_distance: float = 8.0
@export var hover_duration: float = 0.15

@onready var game_title: Control = $fragments
@onready var heading: Control = $choose

@onready var chapter_buttons: Array[Control] = [
	$"chap 1",
	$"chap 2",
	$"chap 3",
	$"chap 4",
	$"chap 5"
]

var original_positions: Dictionary = {}
var hover_tweens: Dictionary = {}
var is_transitioning: bool = false

var chapter_scenes: Dictionary = {
	"chap 1": "res://scenes/CHAPTER 1 Screen.tscn",
	"chap 2": "res://scenes/CHAPTER 2 Screen.tscn",
	"chap 3": "res://scenes/CHAPTER 3 Screen.tscn",
	"chap 4": "res://scenes/CHAPTER 4 Screen.tscn",
	"chap 5": "res://scenes/CHAPTER 5 Screen.tscn"
}


func _enter_tree() -> void:
	for node_name in [
		"fragments",
		"choose",
		"chap 1",
		"chap 2",
		"chap 3",
		"chap 4",
		"chap 5"
	]:
		var node := get_node_or_null(node_name)

		if node is CanvasItem:
			node.hide()


func _ready() -> void:
	# Connect chapter button hover and click signals.
	for button in chapter_buttons:
		if not is_instance_valid(button):
			continue

		original_positions[button] = button.position

		button.mouse_filter = Control.MOUSE_FILTER_STOP

		button.mouse_entered.connect(
			_on_chapter_mouse_entered.bind(button)
		)

		button.mouse_exited.connect(
			_on_chapter_mouse_exited.bind(button)
		)

		button.gui_input.connect(
			_on_chapter_gui_input.bind(button)
		)

	# Animate the game title first.
	var title_position := game_title.position
	game_title.position = title_position + Vector2(0, 6)
	game_title.modulate.a = 0.0
	game_title.show()

	await get_tree().create_timer(title_delay).timeout

	var title_tween := create_tween()
	title_tween.set_parallel(true)

	title_tween.tween_property(
		game_title,
		"modulate:a",
		1.0,
		title_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	title_tween.tween_property(
		game_title,
		"position",
		title_position,
		title_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await title_tween.finished

	# Animate CHOOSE YOUR CHAPTER second.
	var heading_position := heading.position
	heading.pivot_offset = heading.size / 2.0
	heading.scale = Vector2(0.95, 0.95)
	heading.modulate.a = 0.0
	heading.show()

	await get_tree().create_timer(heading_delay).timeout

	var heading_tween := create_tween()
	heading_tween.set_parallel(true)

	heading_tween.tween_property(
		heading,
		"modulate:a",
		1.0,
		heading_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	heading_tween.tween_property(
		heading,
		"scale",
		Vector2.ONE,
		heading_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await heading_tween.finished

	# Reveal chapter buttons one at a time.
	for button in chapter_buttons:
		if not is_instance_valid(button):
			continue

		var original_position: Vector2 = original_positions[button]

		button.position = original_position + Vector2(
			0,
			slide_distance
		)

		button.modulate.a = 0.0
		button.show()

		var button_tween := create_tween()
		button_tween.set_parallel(true)

		button_tween.tween_property(
			button,
			"position",
			original_position,
			button_duration
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		button_tween.tween_property(
			button,
			"modulate:a",
			1.0,
			button_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		await button_tween.finished
		await get_tree().create_timer(button_delay).timeout


func _on_chapter_mouse_entered(button: Control) -> void:
	if is_transitioning:
		return

	if not is_instance_valid(button):
		return

	_animate_chapter_button(
		button,
		original_positions[button] + Vector2(hover_distance, 0)
	)


func _on_chapter_mouse_exited(button: Control) -> void:
	if is_transitioning:
		return

	if not is_instance_valid(button):
		return

	_animate_chapter_button(
		button,
		original_positions[button]
	)


func _animate_chapter_button(
	button: Control,
	target_position: Vector2
) -> void:
	if hover_tweens.has(button):
		var previous_tween: Tween = hover_tweens[button]

		if previous_tween != null and previous_tween.is_running():
			previous_tween.kill()

	var new_tween := create_tween()
	hover_tweens[button] = new_tween

	new_tween.set_trans(Tween.TRANS_QUAD)
	new_tween.set_ease(Tween.EASE_OUT)

	new_tween.tween_property(
		button,
		"position",
		target_position,
		hover_duration
	)


func _on_chapter_gui_input(
	event: InputEvent,
	button: Control
) -> void:
	if is_transitioning:
		return

	if not is_instance_valid(button):
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			button.accept_event()

			var scene_path: String = chapter_scenes.get(
				button.name,
				""
			)

			if scene_path.is_empty():
				push_error(
					"No scene path assigned for: " + button.name
				)
				return

			if not ResourceLoader.exists(scene_path):
				push_error(
					"Scene not found: " + scene_path
				)
				return

			# Get the active SceneTree directly.
			var scene_tree := Engine.get_main_loop() as SceneTree

			if scene_tree == null:
				push_error("Could not access the active SceneTree.")
				return

			is_transitioning = true

			var result: Error = scene_tree.change_scene_to_file(
				scene_path
			)

			if result != OK:
				is_transitioning = false
				push_error(
					"Failed to change scene. Error code: "
					+ str(result)
				)
