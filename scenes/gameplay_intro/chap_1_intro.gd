
extends Control

# CHANGE THIS TO YOUR GAMEPLAY SCENE
@export_file("*.tscn") var gameplay_scene_path: String

# ANIMATION SETTINGS
@export var background_fade_duration: float = 0.3
@export var panel_drop_duration: float = 0.6
@export var title_duration: float = 0.4
@export var description_duration: float = 0.4

@export var reading_duration: float = 2.5
@export var fade_out_duration: float = 0.8

# PANEL MOVEMENT
@export var panel_drop_distance: float = 35.0
@export var panel_swing_angle: float = 1.2

# BACKGROUND ZOOM
@export var background_zoom: float = 1.03


# NODE REFERENCES
@onready var background: TextureRect = $background
@onready var panel: TextureRect = $panel
@onready var title: Label = $title
@onready var description: Label = $description


# ORIGINAL POSITIONS
var panel_original_position: Vector2
var panel_original_rotation: float

var title_original_position: Vector2
var description_original_position: Vector2

var background_original_scale: Vector2


func _ready() -> void:
	# Save original editor positions before animating.
	panel_original_position = panel.position
	panel_original_rotation = panel.rotation

	title_original_position = title.position
	description_original_position = description.position

	background_original_scale = background.scale

	# Prepare initial visual states.
	_prepare_animation()

	# Start the intro animation.
	await _play_intro_animation()

	# Wait for the player to read.
	await get_tree().create_timer(reading_duration).timeout

	# Fade out and load gameplay.
	await _play_exit_animation()


func _prepare_animation() -> void:
	# Background
	background.modulate.a = 0.0
	background.pivot_offset = background.size / 2.0
	background.scale = background_original_scale

	# Wooden panel
	panel.modulate.a = 0.0
	panel.position = panel_original_position + Vector2(
		0,
		-panel_drop_distance
	)

	# Keep the panel's original editor scale and pivot.
	panel.rotation = panel_original_rotation - deg_to_rad(2.0)

	# Title
	title.modulate.a = 0.0
	title.position = title_original_position + Vector2(0, 10)

	# Description
	description.modulate.a = 0.0
	description.position = description_original_position + Vector2(0, 6)


func _play_intro_animation() -> void:

	# ---------------------------------
	# 1. BACKGROUND FADE IN
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
	# 2. WOODEN PANEL ENTRANCE
	# ---------------------------------

	await get_tree().create_timer(0.4).timeout

	var panel_tween = create_tween()
	panel_tween.set_parallel(true)

	panel_tween.tween_property(
		panel,
		"modulate:a",
		1.0,
		panel_drop_duration
	)

	panel_tween.tween_property(
		panel,
		"position",
		panel_original_position,
		panel_drop_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await panel_tween.finished


	# ---------------------------------
	# 3. SUBTLE PANEL SWING
	# ---------------------------------

	var swing_tween = create_tween()

	swing_tween.tween_property(
		panel,
		"rotation",
		panel_original_rotation + deg_to_rad(panel_swing_angle),
		0.35
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	swing_tween.tween_property(
		panel,
		"rotation",
		panel_original_rotation - deg_to_rad(0.6),
		0.35
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	swing_tween.tween_property(
		panel,
		"rotation",
		panel_original_rotation,
		0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await swing_tween.finished


	# ---------------------------------
	# 4. TITLE REVEAL
	# ---------------------------------

	var title_tween = create_tween()
	title_tween.set_parallel(true)

	title_tween.tween_property(
		title,
		"modulate:a",
		1.0,
		title_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	title_tween.tween_property(
		title,
		"position",
		title_original_position,
		title_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await title_tween.finished


	# ---------------------------------
	# 5. DESCRIPTION REVEAL
	# ---------------------------------

	await get_tree().create_timer(0.2).timeout

	var description_tween = create_tween()
	description_tween.set_parallel(true)

	description_tween.tween_property(
		description,
		"modulate:a",
		1.0,
		description_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	description_tween.tween_property(
		description,
		"position",
		description_original_position,
		description_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await description_tween.finished



func _play_exit_animation() -> void:

	if gameplay_scene_path == "":
		push_warning("Gameplay scene path has not been assigned!")
		return

	# Load the next scene first, without displaying it yet.
	var next_scene = load(gameplay_scene_path)

	if next_scene == null:
		push_error("Could not load gameplay scene: " + gameplay_scene_path)
		return

	# Fade the current intro scene to black.
	var exit_tween = create_tween()

	exit_tween.tween_property(
		self,
		"modulate:a",
		0.0,
		fade_out_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await exit_tween.finished

	# Immediately switch to the already-loaded gameplay scene.
	get_tree().change_scene_to_packed(next_scene)

		
