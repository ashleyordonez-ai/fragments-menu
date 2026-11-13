
extends Control


# =====================================================
# TIMING
# =====================================================

const DIALOGUE_FADE_TIME := 0.6
const DIALOGUE_HOLD_TIME := 3.0

const DIALOGUE_CHAR_DELAY := 0.055
const DIALOGUE_POP_TIME := 0.4

const GEAR_REVEAL_TIME := 0.8
const GEAR_GLOW_HOLD_TIME := 1.0

const INSTRUCTION_FADE_TIME := 0.6
const INSTRUCTION_HOLD_TIME := 3.0

const SUCCESS_DIM_TIME := 0.5
const SUCCESS_GLOW_TIME := 0.8

# Recovered gear pulse
const GEAR_PULSE_TIME := 1.2

# Scene fade-in
const SCENE_FADE_IN_TIME := 1.5


# =====================================================
# NODE REFERENCES
# =====================================================

@onready var recovered_gear: CanvasItem = $RecoveredGear

@onready var dialogue_ui: Control = $DialogueLayer/DialogueUI
@onready var dialogue_dim: ColorRect = $DialogueLayer/DialogueUI/DialogueDim
@onready var dialogue_panel: Control = $DialogueLayer/DialogueUI/DialoguePanel
@onready var dialogue_label: Label = $DialogueLayer/DialogueUI/DialoguePanel/DialogueLabel

@onready var instruction_ui: Control = $InstructionLayer/InstructionUI
@onready var instruction_dim: ColorRect = $InstructionLayer/InstructionUI/InstructionDim
@onready var instruction_panel: Control = $InstructionLayer/InstructionUI/InstructionPanel
@onready var instruction_title: Label = $InstructionLayer/InstructionUI/InstructionPanel/InstructionTitle
@onready var instruction_text: Label = $InstructionLayer/InstructionUI/InstructionPanel/InstructionText


# =====================================================
# DRAG AND DROP
# =====================================================

var is_dragging := false
var drag_offset := Vector2.ZERO
var gear_start_position := Vector2.ZERO

var gear_pulse_tween: Tween

@onready var missing_gear_glow: ColorRect = $MissingGearGlow


# =====================================================
# READY
# =====================================================

func _ready():
	print("GEAR REPAIR SCRIPT IS RUNNING")

	# Initial visibility
	recovered_gear.hide()
	dialogue_ui.hide()

	instruction_ui.hide()
	instruction_ui.modulate.a = 0.0

	# Store the gear's starting position
	gear_start_position = recovered_gear.global_position

	# Fade in the scene from black
	var scene_fade := ColorRect.new()
	scene_fade.name = "SceneFadeIn"
	scene_fade.color = Color.BLACK
	scene_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene_fade.z_as_relative = false
	scene_fade.z_index = 200

	add_child(scene_fade)

	var scene_fade_tween := create_tween()
	scene_fade_tween.tween_property(
		scene_fade,
		"modulate:a",
		0.0,
		SCENE_FADE_IN_TIME
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await scene_fade_tween.finished
	scene_fade.queue_free()

	# Start the sequence
	start_gear_repair_sequence()


# =====================================================
# MAIN SEQUENCE
# =====================================================

func start_gear_repair_sequence():

	# Make sure the recovered gear starts hidden
	recovered_gear.hide()

	# Make sure dialogue starts hidden
	dialogue_ui.hide()
	dialogue_ui.modulate.a = 0.0

	# Make sure instruction starts hidden
	instruction_ui.hide()
	instruction_ui.modulate.a = 0.0

	# -------------------------------------------------
	# 1. DIALOGUE APPEARS
	# -------------------------------------------------

	await show_gear_dialogue()

	# -------------------------------------------------
	# 2. RECOVERED GEAR APPEARS ON THE RIGHT
	# -------------------------------------------------

	await reveal_recovered_gear()

	# -------------------------------------------------
	# 3. RECOVERED GEAR BRIEFLY GLOWS GOLD
	# -------------------------------------------------

	await briefly_highlight_recovered_gear()

	# -------------------------------------------------
	# 4. DIM EVERYTHING AND SHOW DRAG INSTRUCTION
	# -------------------------------------------------

	await show_drag_instruction()

	# NEXT STEP:
	# Player can now drag the recovered gear.


# =====================================================
# DIALOGUE
# =====================================================

func show_gear_dialogue():

	dialogue_ui.show()
	dialogue_ui.modulate.a = 0.0

	# Prepare dialogue text for typing effect
	dialogue_label.visible_characters = 0

	# Prepare panel for pop-up animation
	dialogue_panel.pivot_offset = dialogue_panel.size / 2.0
	dialogue_panel.scale = Vector2(0.85, 0.85)

	# Fade in dialogue
	var fade_in := create_tween()

	fade_in.tween_property(
		dialogue_ui,
		"modulate:a",
		1.0,
		DIALOGUE_FADE_TIME
	)

	# Pop up the dialogue panel
	var panel_pop := create_tween()

	panel_pop.set_trans(Tween.TRANS_BACK)
	panel_pop.set_ease(Tween.EASE_OUT)

	panel_pop.tween_property(
		dialogue_panel,
		"scale",
		Vector2.ONE,
		DIALOGUE_POP_TIME
	)

	await fade_in.finished

	# Type the dialogue character by character
	var dialogue_length = dialogue_label.text.length()

	for i in range(dialogue_length):
		dialogue_label.visible_characters = i + 1

		await get_tree().create_timer(
			DIALOGUE_CHAR_DELAY
		).timeout

	dialogue_label.visible_characters = -1

	# Keep dialogue visible
	await get_tree().create_timer(
		DIALOGUE_HOLD_TIME
	).timeout

	# Fade out dialogue
	var fade_out := create_tween()

	fade_out.tween_property(
		dialogue_ui,
		"modulate:a",
		0.0,
		DIALOGUE_FADE_TIME
	)

	await fade_out.finished

	# Hide dialogue completely
	dialogue_ui.hide()


# =====================================================
# RECOVERED GEAR REVEAL
# =====================================================

func reveal_recovered_gear():

	# Show gear at its editor position
	recovered_gear.show()
	recovered_gear.modulate = Color.WHITE
	recovered_gear.modulate.a = 0.0

	# Fade in
	var gear_tween := create_tween()

	gear_tween.tween_property(
		recovered_gear,
		"modulate:a",
		1.0,
		GEAR_REVEAL_TIME
	)

	await gear_tween.finished


# =====================================================
# BRIEF GOLD HIGHLIGHT
# =====================================================

func briefly_highlight_recovered_gear():

	# Bright gold
	var glow_tween := create_tween()

	glow_tween.tween_property(
		recovered_gear,
		"modulate",
		Color(2.0, 1.65, 0.65, 1.0),
		0.3
	)

	# Hold the gold brightness
	glow_tween.tween_interval(
		GEAR_GLOW_HOLD_TIME
	)

	# Return to normal
	glow_tween.tween_property(
		recovered_gear,
		"modulate",
		Color.WHITE,
		0.4
	)

	await glow_tween.finished


# =====================================================
# DRAG INSTRUCTION
# =====================================================

func show_drag_instruction():

	# Show dim overlay and instruction panel
	instruction_ui.show()
	instruction_ui.modulate.a = 0.0

	# Fade in instruction UI
	var fade_in := create_tween()

	fade_in.tween_property(
		instruction_ui,
		"modulate:a",
		1.0,
		INSTRUCTION_FADE_TIME
	)

	await fade_in.finished

	# Keep instruction visible
	await get_tree().create_timer(
		INSTRUCTION_HOLD_TIME
	).timeout

	# Fade out instruction UI
	var fade_out := create_tween()

	fade_out.tween_property(
		instruction_ui,
		"modulate:a",
		0.0,
		INSTRUCTION_FADE_TIME
	)

	await fade_out.finished

	# Hide instruction UI completely
	instruction_ui.hide()

	# Start a subtle pulse to show the gear is clickable
	start_gear_pulse()


# =====================================================
# GEAR DRAGGING
# =====================================================

func _input(event):

	# Only allow dragging after the instruction UI disappears
	if instruction_ui.visible:
		return

	# Don't allow dragging before the gear is revealed
	if not recovered_gear.visible:
		return

	# Start dragging when the player clicks the gear
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:
				if recovered_gear.get_global_rect().has_point(
					get_global_mouse_position()
				):
					is_dragging = true

					# Stop the pulse while the gear is being dragged
					stop_gear_pulse()

					drag_offset = (
						recovered_gear.global_position
						- get_global_mouse_position()
					)

					recovered_gear.z_index = 10

			else:
				if is_dragging:
					is_dragging = false
					recovered_gear.z_index = 0

					check_gear_placement()


	# Move the gear while dragging
	if event is InputEventMouseMotion and is_dragging:

		recovered_gear.global_position = (
			get_global_mouse_position()
			+ drag_offset
		)


# =====================================================
# CHECK GEAR PLACEMENT
# =====================================================

func check_gear_placement():

	# Get the center of the missing gear slot
	var target_position = (
		missing_gear_glow.global_position
		+ missing_gear_glow.size / 2.0
	)

	# Get the center of the recovered gear
	var recovered_gear_center = (
		recovered_gear.global_position
		+ (recovered_gear as Control).size / 2.0
	)

	var distance = recovered_gear_center.distance_to(
		target_position
	)

	if distance <= 100.0:

		# Snap the recovered gear to the center of the missing gear slot
		recovered_gear.global_position = (
			target_position
			- (recovered_gear as Control).size / 2.0
		)

		# Hide the missing gear glow and its child ring
		missing_gear_glow.hide()

		# Stop further dragging
		(recovered_gear as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE

		print("GEAR SUCCESSFULLY PLACED!")

		# Play the successful placement sequence
		await play_gear_success_sequence()

	else:

		# Return the gear to its original position
		var return_tween = create_tween()

		return_tween.tween_property(
			recovered_gear,
			"global_position",
			gear_start_position,
			0.3
		)


# =====================================================
# SUCCESSFUL GEAR PLACEMENT
# =====================================================


func play_gear_success_sequence():

	# Prevent further dragging
	is_dragging = false
	(recovered_gear as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Bright gold glow on the recovered gear
	var glow_tween = create_tween()

	glow_tween.tween_property(
		recovered_gear,
		"modulate",
		Color(2.5, 2.0, 0.7, 1.0),
		0.3
	)

	glow_tween.tween_interval(
		SUCCESS_GLOW_TIME
	)

	await glow_tween.finished

	# Create a black transition overlay
	var transition_overlay := ColorRect.new()
	transition_overlay.name = "SceneTransitionOverlay"
	transition_overlay.color = Color(0, 0, 0, 0)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.z_index = 200
	transition_overlay.z_as_relative = false
	transition_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	add_child(transition_overlay)
	transition_overlay.move_to_front()

	# Fade to black before changing scenes
	var fade_tween := create_tween()

	fade_tween.tween_property(
		transition_overlay,
		"color:a",
		1.0,
		0.75
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await fade_tween.finished

	# Change to MusicBoxPlaying while the screen is black
	get_tree().change_scene_to_file(
		"res://scene/MusicBoxPlaying.tscn"
	)



# =====================================================
# RECOVERED GEAR PULSE
# =====================================================

func start_gear_pulse():

	# Stop any existing pulse
	if gear_pulse_tween and gear_pulse_tween.is_running():
		gear_pulse_tween.kill()

	# Keep the gear at its normal color
	recovered_gear.modulate = Color.WHITE

	# Create a subtle repeating pulse
	gear_pulse_tween = create_tween()
	gear_pulse_tween.set_loops()

	gear_pulse_tween.tween_property(
		recovered_gear,
		"modulate",
		Color(1.25, 1.15, 0.8, 1.0),
		GEAR_PULSE_TIME / 2.0
	)

	gear_pulse_tween.tween_property(
		recovered_gear,
		"modulate",
		Color.WHITE,
		GEAR_PULSE_TIME / 2.0
	)


func stop_gear_pulse():

	if gear_pulse_tween and gear_pulse_tween.is_running():
		gear_pulse_tween.kill()

	recovered_gear.modulate = Color.WHITE
