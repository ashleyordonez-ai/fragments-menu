
extends TextureRect

@export var hover_distance: float = 8.0
@export var animation_time: float = 0.15
@export var glitch_intensity: float = 3.0

var original_position: Vector2
var tween: Tween
var glitch_tween: Tween


func _ready() -> void:
	original_position = position
	mouse_filter = Control.MOUSE_FILTER_STOP

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	_animate_button(original_position + Vector2(hover_distance, 0))
	_start_glitch()


func _on_mouse_exited() -> void:
	_stop_glitch()
	_animate_button(original_position)


func _animate_button(target_position: Vector2) -> void:
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_position, animation_time)


func _start_glitch() -> void:
	if glitch_tween and glitch_tween.is_running():
		glitch_tween.kill()

	glitch_tween = create_tween()
	glitch_tween.set_loops()

	glitch_tween.tween_property(
		self,
		"position",
		original_position + Vector2(hover_distance + glitch_intensity, 0),
		0.04
	)

	glitch_tween.tween_property(
		self,
		"position",
		original_position + Vector2(hover_distance - glitch_intensity, 0),
		0.04
	)

	glitch_tween.tween_property(
		self,
		"position",
		original_position + Vector2(hover_distance, 0),
		0.06
	)

	glitch_tween.tween_interval(0.8)


func _stop_glitch() -> void:
	if glitch_tween and glitch_tween.is_running():
		glitch_tween.kill()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_viewport().set_input_as_handled()
			get_tree().change_scene_to_file(
				"res://scene/ChapterSelection.tscn"
			)
