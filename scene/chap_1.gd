
extends TextureRect

@export var hover_distance: float = 8.0
@export var animation_time: float = 0.15

var original_position: Vector2
var tween: Tween

func _ready() -> void:
	original_position = position
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	_animate_button(original_position + Vector2(hover_distance, 0))


func _on_mouse_exited() -> void:
	_animate_button(original_position)


func _animate_button(target_position: Vector2) -> void:
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_position, animation_time)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_viewport().set_input_as_handled()
			get_tree().change_scene_to_file("res://scene/Chapter1.tscn")
