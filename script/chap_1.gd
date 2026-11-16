
extends TextureRect

@export var hover_distance: float = 8.0
@export var animation_time: float = 0.15

# Destination scene
@export_file("*.tscn") var target_scene: String


var original_position: Vector2
var tween: Tween


func _ready() -> void:

	original_position = position

	# Allow the TextureRect to detect mouse clicks
	mouse_filter = Control.MOUSE_FILTER_STOP

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


# =====================================
# HOVER ANIMATION
# =====================================

func _on_mouse_entered() -> void:

	_animate_button(
		original_position + Vector2(hover_distance, 0)
	)


func _on_mouse_exited() -> void:

	_animate_button(original_position)


func _animate_button(target_position: Vector2) -> void:

	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"position",
		target_position,
		animation_time
	)


# =====================================
# BUTTON CLICK
# =====================================

func _on_gui_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			get_viewport().set_input_as_handled()

			print("CHAPTER 1 BUTTON CLICKED!")

			if target_scene.is_empty():
				push_error("Target scene has not been assigned!")
				return

			if ResourceLoader.exists(target_scene):

				print("LOADING SCENE: ", target_scene)

				var error = get_tree().change_scene_to_file(target_scene)

				if error != OK:
					push_error("Failed to load Chapter 1 Scene!")

			else:
				push_error("Scene not found: " + target_scene)
