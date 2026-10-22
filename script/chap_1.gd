
extends TextureRect

@export var hover_distance: float = 8.0
@export var animation_time: float = 0.15
@export_file("*.tscn") var target_scene: String = "res://scene/Chapter 1/Chapter1_Scene 1.1.tscn"

var original_position: Vector2
var tween: Tween

func _ready() -> void:
	original_position = position
	mouse_filter = Control.MOUSE_FILTER_STOP

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


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


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_viewport().set_input_as_handled()

			if ResourceLoader.exists(target_scene):
				get_tree().change_scene_to_file(target_scene)
			else:
				push_error("Scene not found: " + target_scene)
