
extends Control

@onready var fill_clip: Control = $FillClip
@onready var sanity_fill: TextureRect = $FillClip/SanityFill

var full_bar_height: float
var full_bar_bottom: float
var full_fill_position_y: float
var fill_tween: Tween


func _ready() -> void:
	full_bar_height = fill_clip.size.y
	full_bar_bottom = fill_clip.position.y + fill_clip.size.y
	full_fill_position_y = sanity_fill.position.y

	SanityManager.sanity_changed.connect(update_sanity)

	update_sanity(SanityManager.current_sanity, false)


func update_sanity(value: int, animate: bool = true) -> void:
	var percentage := clampf(float(value) / 100.0, 0.0, 1.0)
	var target_height := full_bar_height * percentage
	var target_position_y := full_bar_bottom - target_height
	var target_fill_position_y := full_fill_position_y - (full_bar_height - target_height)

	if fill_tween and fill_tween.is_running():
		fill_tween.kill()

	if not animate:
		fill_clip.position.y = target_position_y
		fill_clip.size.y = target_height
		sanity_fill.position.y = target_fill_position_y
		return

	fill_tween = create_tween()
	fill_tween.set_parallel(true)

	fill_tween.tween_property(
		fill_clip,
		"position:y",
		target_position_y,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	fill_tween.tween_property(
		fill_clip,
		"size:y",
		target_height,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	fill_tween.tween_property(
		sanity_fill,
		"position:y",
		target_fill_position_y,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
