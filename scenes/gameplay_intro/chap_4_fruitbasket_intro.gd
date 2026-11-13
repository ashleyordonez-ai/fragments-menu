
extends Control

# ==================================================
# SCENE SETTINGS
# ==================================================

@export_file("*.tscn") var gameplay_scene_path: String


# ==================================================
# ANIMATION SETTINGS
# ==================================================

@export var background_fade_duration: float = 0.8
@export var frame_duration: float = 0.9
@export var title_duration: float = 0.7
@export var description_duration: float = 0.7

@export var reading_duration: float = 2.5
@export var fade_out_duration: float = 0.6


# ==================================================
# VISUAL SETTINGS
# ==================================================

@export var background_zoom: float = 1.10
@export var frame_start_scale: float = 0.94


# ==================================================
# NODE REFERENCES
# ==================================================

@onready var background: TextureRect = $background
@onready var frame: TextureRect = $TextureRect
@onready var title: Label = $title
@onready var description: Label = $description


# ==================================================
# ORIGINAL SCALES
# ==================================================

var background_original_scale: Vector2
var frame_original_scale: Vector2


# ==================================================
# READY
# ==================================================

func _ready() -> void:

	# Save original scales from the editor.
	background_original_scale = background.scale
	frame_original_scale = frame.scale

	# Prepare initial visual states.
	_prepare_animation()

	# Play intro animation.
	await _play_intro_animation()

	# Reading pause.
	await get_tree().create_timer(reading_duration).timeout

	# Fade out and load gameplay.
	await _play_exit_animation()


# ==================================================
# PREPARE ANIMATION
# ==================================================

func _prepare_animation() -> void:

	# Reset scene opacity.
	modulate = Color.WHITE

	# BACKGROUND
	background.modulate.a = 0.0
	background.pivot_offset = background.size / 2.0
	background.scale = background_original_scale

	# FLORAL FRAME
	frame.modulate.a = 0.0
	frame.pivot_offset = frame.size / 2.0
	frame.scale = frame_original_scale * frame_start_scale

	# TITLE
	title.modulate.a = 0.0

	# DESCRIPTION
	description.modulate.a = 0.0


# ==================================================
# INTRO ANIMATION
# ==================================================

func _play_intro_animation() -> void:

	# ---------------------------------
	# 1. BACKGROUND FADE + ZOOM
	# ---------------------------------

	var background_tween := create_tween()
	background_tween.set_parallel(true)

	background_tween.tween_property(
		background,
		"modulate:a",
		1.0,
		background_fade_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	background_tween.tween_property(
		background,
		"scale",
		background_original_scale * background_zoom,
		4.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


	# ---------------------------------
	# 2. FLORAL FRAME REVEAL
	# ---------------------------------

	await get_tree().create_timer(0.35).timeout

	var frame_tween := create_tween()
	frame_tween.set_parallel(true)

	frame_tween.tween_property(
		frame,
		"modulate:a",
		1.0,
		frame_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	frame_tween.tween_property(
		frame,
		"scale",
		frame_original_scale,
		frame_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await frame_tween.finished


	# ---------------------------------
	# 3. TITLE REVEAL
	# ---------------------------------

	var title_tween := create_tween()

	title_tween.tween_property(
		title,
		"modulate:a",
		1.0,
		title_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await title_tween.finished


	# ---------------------------------
	# 4. DESCRIPTION REVEAL
	# ---------------------------------

	await get_tree().create_timer(0.2).timeout

	var description_tween := create_tween()

	description_tween.tween_property(
		description,
		"modulate:a",
		1.0,
		description_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await description_tween.finished


# ==================================================
# EXIT ANIMATION
# ==================================================

func _play_exit_animation() -> void:

	# Create black overlay above the intro scene.
	var fade_overlay := ColorRect.new()
	fade_overlay.name = "FadeOverlay"
	fade_overlay.color = Color.BLACK
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	fade_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	fade_overlay.z_as_relative = false
	fade_overlay.z_index = 4096
	fade_overlay.modulate.a = 0.0

	add_child(fade_overlay)

	# Fade smoothly to black.
	var exit_tween := create_tween()

	exit_tween.tween_property(
		fade_overlay,
		"modulate:a",
		1.0,
		fade_out_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await exit_tween.finished

	# Load gameplay scene.
	if gameplay_scene_path != "":
		get_tree().change_scene_to_file(gameplay_scene_path)
	else:
		push_warning("Gameplay scene path has not been assigned!")
