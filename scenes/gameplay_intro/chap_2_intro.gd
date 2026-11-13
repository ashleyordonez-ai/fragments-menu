
extends Control

# CHANGE THIS TO YOUR GAMEPLAY SCENE
@export_file("*.tscn") var gameplay_scene_path: String


# ANIMATION SETTINGS
@export var background_fade_duration: float = 0.8
@export var paper_duration: float = 0.9
@export var title_duration: float = 0.7
@export var description_duration: float = 0.7

@export var reading_duration: float = 2.5
@export var fade_out_duration: float = 0.5

# VISUAL SETTINGS
@export var background_zoom: float = 1.10
@export var paper_start_scale: float = 0.94


# NODE REFERENCES
@onready var background: TextureRect = $background
@onready var paper: TextureRect = $paper
@onready var title: Label = $title
@onready var description: Label = $description


# ORIGINAL SCALES
var background_original_scale: Vector2
var paper_original_scale: Vector2

var gameplay_scene: PackedScene


func _ready() -> void:
	
	if gameplay_scene_path != "":
		gameplay_scene = load(gameplay_scene_path) as PackedScene
	
	# Save original scales from the editor.
	background_original_scale = background.scale
	paper_original_scale = paper.scale

	# Prepare animation.
	_prepare_animation()

	# Play intro.
	await _play_intro_animation()

	# Give the player time to read.
	await get_tree().create_timer(reading_duration).timeout

	# Fade out and load gameplay.
	await _play_exit_animation()


func _prepare_animation() -> void:

	# Reset scene opacity.
	modulate = Color.WHITE

	# BACKGROUND
	background.modulate.a = 0.0
	background.pivot_offset = background.size / 2.0
	background.scale = background_original_scale

	# PAPER
	paper.modulate.a = 0.0
	paper.pivot_offset = paper.size / 2.0
	paper.scale = paper_original_scale * paper_start_scale

	# TITLE
	title.modulate.a = 0.0

	# DESCRIPTION
	description.modulate.a = 0.0


func _play_intro_animation() -> void:

	# ---------------------------------
	# 1. BACKGROUND FADE IN + ZOOM
	# ---------------------------------

	var background_tween = create_tween()
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
		3.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


	# ---------------------------------
	# 2. PAPER REVEAL
	# ---------------------------------

	await get_tree().create_timer(0.35).timeout

	var paper_tween = create_tween()
	paper_tween.set_parallel(true)

	paper_tween.tween_property(
		paper,
		"modulate:a",
		1.0,
		paper_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	paper_tween.tween_property(
		paper,
		"scale",
		paper_original_scale,
		paper_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await paper_tween.finished


	# ---------------------------------
	# 3. TITLE REVEAL
	# ---------------------------------

	var title_tween = create_tween()

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

	var description_tween = create_tween()

	description_tween.tween_property(
		description,
		"modulate:a",
		1.0,
		description_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await description_tween.finished


func _play_exit_animation() -> void:

	# Fade the entire intro scene to black.
	var exit_tween = create_tween()

	exit_tween.tween_property(
		self,
		"modulate:a",
		0.0,
		fade_out_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await exit_tween.finished

	# Load gameplay scene.
	if gameplay_scene_path != "":
		get_tree().change_scene_to_file(gameplay_scene_path)
	else:
		push_warning("Gameplay scene path has not been assigned!")


# ==================================================
# SCENE TRANSITION — FADE IN FROM BLACK
# ==================================================

func create_transition_overlay() -> ColorRect:
	var overlay := ColorRect.new()
	overlay.name = "TransitionOverlay"

	overlay.color = Color.BLACK
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	overlay.z_as_relative = false
	overlay.z_index = 4096

	add_child(overlay)

	return overlay


func fade_in_from_black(overlay: ColorRect) -> void:
	var fade_tween := create_tween()

	fade_tween.tween_property(
		overlay,
		"modulate:a",
		0.0,
		0.7
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await fade_tween.finished

	overlay.queue_free()
