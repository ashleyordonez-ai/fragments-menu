
extends Control

@export var title_delay: float = 0.25
@export var title_duration: float = 0.6
@export var heading_delay: float = 0.2
@export var heading_duration: float = 0.4
@export var button_delay: float = 0.15
@export var button_duration: float = 0.4
@export var slide_distance: float = 10.0

@onready var game_title: Control = $fragments
@onready var heading: Control = $choose

@onready var chapter_buttons: Array[Control] = [
	$"chap 1",
	$"chap 2",
	$"chap 3",
	$"chap 4",
	$"chap 5"
]


func _enter_tree() -> void:
	# Hide everything before the scene is displayed.
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
	# Animate the game title first.
	var title_position := game_title.position
	game_title.position = title_position + Vector2(0, 6)
	game_title.modulate.a = 0.0
	game_title.show()

	await get_tree().create_timer(title_delay).timeout

	var title_tween := create_tween()
	title_tween.set_parallel(true)

	title_tween.tween_property(
		game_title, "modulate:a", 1.0, title_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	title_tween.tween_property(
		game_title, "position", title_position, title_duration
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
		heading, "modulate:a", 1.0, heading_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	heading_tween.tween_property(
		heading, "scale", Vector2.ONE, heading_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await heading_tween.finished

	# Reveal the chapter buttons one at a time.
	for button in chapter_buttons:
		if not is_instance_valid(button):
			continue

		var original_position := button.position

		button.position = original_position + Vector2(
			0, slide_distance
		)
		button.modulate.a = 0.0
		button.show()

		var button_tween := create_tween()
		button_tween.set_parallel(true)

		button_tween.tween_property(
			button, "position", original_position, button_duration
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		button_tween.tween_property(
			button, "modulate:a", 1.0, button_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		await button_tween.finished
		await get_tree().create_timer(button_delay).timeout
