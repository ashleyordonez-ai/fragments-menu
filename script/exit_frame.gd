
extends Control

@export var hover_distance: float = 8.0
@export var animation_time: float = 0.15
@export var press_scale: float = 0.96

var original_position: Vector2
var original_scale: Vector2
var effect_tween: Tween
var hovering: bool = false
var pressed: bool = false

@onready var label: Label = $exitbutton


func _ready() -> void:
	original_position = position
	original_scale = scale
	pivot_offset = size / 2.0

	label.mouse_filter = Control.MOUSE_FILTER_STOP
	label.mouse_entered.connect(_on_hover_entered)
	label.mouse_exited.connect(_on_hover_exited)
	label.gui_input.connect(_on_label_input)


func _on_hover_entered() -> void:
	hovering = true
	animate_effect(
		original_position + Vector2(hover_distance, 0),
		original_scale
	)


func _on_hover_exited() -> void:
	hovering = false

	if not pressed:
		animate_effect(original_position, original_scale)


func _on_label_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pressed = true

				var target_position := original_position
				if hovering:
					target_position.x += hover_distance

				animate_effect(
					target_position,
					original_scale * press_scale
				)
			else:
				pressed = false

				var target_position := original_position
				if hovering:
					target_position.x += hover_distance

				animate_effect(target_position, original_scale)


func animate_effect(
	target_position: Vector2,
	target_scale: Vector2
) -> void:
	if effect_tween and effect_tween.is_running():
		effect_tween.kill()

	effect_tween = create_tween()
	effect_tween.set_trans(Tween.TRANS_QUAD)
	effect_tween.set_ease(Tween.EASE_OUT)
	effect_tween.set_parallel(true)

	effect_tween.tween_property(
		self, "position", target_position, animation_time
	)
	effect_tween.tween_property(
		self, "scale", target_scale, animation_time
	)
