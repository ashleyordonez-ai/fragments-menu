
extends Button

@onready var hover_effect: TextureRect = $HoverEffect

var original_position: Vector2
var tween: Tween

func _ready():
	original_position = position
	hover_effect.hide()

	# Hover effect signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# Start button click signal
	pressed.connect(_on_startbutton_pressed)


func _on_mouse_entered():
	hover_effect.show()
	animate_button(original_position + Vector2(0, -8))


func _on_mouse_exited():
	hover_effect.hide()
	animate_button(original_position)


func animate_button(target_position: Vector2):
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_position, 0.15)

func _on_startbutton_pressed():
	get_tree().change_scene_to_file("res://scene/ChapterSelection.tscn")
