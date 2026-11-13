
extends Control

@onready var slider_track: TextureRect = $SliderTrack
@onready var slider_knob: Control = $SliderKnob
@onready var knob_image: TextureRect = $SliderKnob/KnobImage

var dragging := false
var drag_offset := 0.0
var volume_value := 0.0

var start_x := 0.0
var end_x := 0.0


func _ready() -> void:
	await get_tree().process_frame

	# Your editor-defined starting position is ALWAYS 0%.
	start_x = slider_knob.position.x

	# The available horizontal travel distance is the track width.
	end_x = start_x + slider_track.size.x

	# Start at 0%.
	volume_value = 0.0

	print("Starting knob X: ", start_x)
	print("Ending knob X: ", end_x)
	print("Track width: ", slider_track.size.x)


func _input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:
				var mouse_pos := get_local_mouse_position()

				var image_rect := Rect2(
					slider_knob.position + knob_image.position,
					knob_image.size
				)

				if image_rect.has_point(mouse_pos):
					dragging = true
					drag_offset = mouse_pos.x - slider_knob.position.x
					get_viewport().set_input_as_handled()

			else:
				dragging = false


	elif event is InputEventMouseMotion and dragging:

		var mouse_x := get_local_mouse_position().x

		slider_knob.position.x = clampf(
			mouse_x - drag_offset,
			start_x,
			end_x
		)

		_update_volume_value()
		get_viewport().set_input_as_handled()


func _update_volume_value() -> void:

	var progress := inverse_lerp(
		start_x,
		end_x,
		slider_knob.position.x
	)

	volume_value = clampf(progress * 100.0, 0.0, 100.0)

	print("Volume: ", roundi(volume_value))
