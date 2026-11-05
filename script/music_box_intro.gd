extends Control


# =========================================================
# NODE REFERENCES — MATCHING YOUR SCENE TREE
# =========================================================

@onready var dim_overlay: ColorRect = \
	$DimLayer/DimOverlay

@onready var first_panel: Control = \
	$CanvasLayer/IntroUI/InstructionPanel

@onready var first_label: Label = \
	$CanvasLayer/IntroUI/InstructionPanel/InstructionLabel

@onready var second_panel: Control = \
	$SecondInstructionLayer/SecondInstruction

@onready var second_heading: Label = \
	$SecondInstructionLayer/SecondInstruction/Heading

@onready var second_label: Label = \
	$SecondInstructionLayer/SecondInstruction/InstructionText

@onready var continue_button: Button = \
	$SecondInstructionLayer/SecondInstruction/ContinueButton

@onready var missing_gear_glow: Control = \
	$MissingGearLayer/MissingGearGlow


# =========================================================
# TIMING
# =========================================================

const GEAR_GLITCH_WAIT := 4.0

const FIRST_PANEL_FADE_TIME := 1.0
const FIRST_PANEL_HOLD := 4.0

const BETWEEN_PANELS_WAIT := 1.2
const SECOND_PANEL_FADE_TIME := 1.0

const TYPE_SPEED := 0.08

const SECOND_PANEL_HOLD_AFTER_TYPING := 3.0
const MISSING_GEAR_GLOW_HOLD := 3.0

const BUTTON_FADE_TIME := 0.8


# =========================================================
# TEXT
# =========================================================

const FIRST_INSTRUCTION := \
	"Something is wrong with the music box..."


# =========================================================
# COLORS
# =========================================================

const DIM_COLOR := Color(0.035, 0.025, 0.055, 0.78)

const SECOND_GLOW_COLOR := Color(1.0, 0.72, 0.30, 0.18)
const SECOND_GLOW_SIZE := 18

const BUTTON_NORMAL_COLOR := Color("#49364F")
const BUTTON_HOVER_COLOR := Color("#604766")
const BUTTON_PRESSED_COLOR := Color("#35263B")

const BUTTON_BORDER_COLOR := Color("#B99A68")
const BUTTON_HOVER_BORDER_COLOR := Color("#D7B77D")
const BUTTON_PRESSED_BORDER_COLOR := Color("#A88758")

const BUTTON_TEXT_COLOR := Color("#F2E8D8")
const BUTTON_HOVER_TEXT_COLOR := Color("#FFF4D8")
const BUTTON_PRESSED_TEXT_COLOR := Color("#D8C4A3")


# =========================================================
# VARIABLES
# =========================================================

var second_panel_glow: Panel
var sequence_running := false


# =========================================================
# READY
# =========================================================

func _ready() -> void:
	print("Button visible: ", continue_button.is_visible_in_tree())
	print("Button disabled: ", continue_button.disabled)
	print("Button rect: ", continue_button.get_global_rect())

	continue_button.mouse_entered.connect(func():
		print("BUTTON MOUSE ENTERED")
	)

	continue_button.gui_input.connect(func(event):
		if event is InputEventMouseButton:
			print("BUTTON GUI INPUT: ", event)
	)

	var parent_control = continue_button.get_parent()

	print("Button parent: ", parent_control.name)
	print("Parent mouse filter: ", parent_control.mouse_filter)
	print("Button mouse filter: ", continue_button.mouse_filter)
	print("Button mouse position: ", continue_button.get_global_mouse_position())

	setup_ui()
	setup_second_panel_glow()
	setup_continue_button()

	start_intro_sequence()


# =========================================================
# INITIAL UI SETUP
# =========================================================

func setup_ui() -> void:

	# -----------------------------------------------------
	# DIM OVERLAY
	# -----------------------------------------------------

	dim_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim_overlay.color = DIM_COLOR
	dim_overlay.modulate.a = 0.0
	dim_overlay.hide()


	# -----------------------------------------------------
	# FIRST INSTRUCTION PANEL
	# -----------------------------------------------------

	first_panel.hide()
	first_panel.modulate.a = 0.0

	first_label.text = FIRST_INSTRUCTION
	first_label.visible_characters = 0


	# -----------------------------------------------------
	# SECOND INSTRUCTION PANEL
	# -----------------------------------------------------

	second_panel.hide()
	second_panel.modulate.a = 0.0

	# Keep the text you already set in the Inspector.
	second_label.visible_characters = 0

	second_heading.modulate.a = 0.0


	# -----------------------------------------------------
	# MISSING GEAR GLOW
	# -----------------------------------------------------

	missing_gear_glow.hide()


# =========================================================
# SECOND PANEL CONTINUOUS TRAVELING LIGHT
# =========================================================

func setup_second_panel_glow() -> void:

	second_panel_glow = Panel.new()

	second_panel_glow.name = "SecondInstructionGlow"
	second_panel_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Slightly larger than the instruction panel.
	second_panel_glow.position = Vector2(-6, -6)
	second_panel_glow.size = second_panel.size + Vector2(12, 12)

	var glow_shader := Shader.new()

	glow_shader.code = """
	shader_type canvas_item;

	uniform vec4 base_glow_color : source_color = vec4(0.75, 0.48, 0.22, 0.22);
	uniform vec4 moving_light_color : source_color = vec4(1.0, 0.82, 0.48, 0.95);

	uniform float border_thickness : hint_range(0.001, 0.08) = 0.018;
	uniform float light_length : hint_range(0.05, 0.5) = 0.18;
	uniform float light_speed : hint_range(0.1, 2.0) = 0.35;

	void fragment() {
		vec2 uv = UV;

		float edge = min(
			min(uv.x, 1.0 - uv.x),
			min(uv.y, 1.0 - uv.y)
		);

		float border = 1.0 - smoothstep(
			border_thickness,
			border_thickness + 0.012,
			edge
		);

		float perimeter;

		if (uv.y < 0.05) {
			perimeter = uv.x;
		} else if (uv.x > 0.95) {
			perimeter = 1.0 + uv.y;
		} else if (uv.y > 0.95) {
			perimeter = 2.0 + (1.0 - uv.x);
		} else {
			perimeter = 3.0 + (1.0 - uv.y);
		}

		perimeter /= 4.0;

		float light_position = fract(TIME * light_speed);

		float distance_to_light = abs(perimeter - light_position);

		distance_to_light = min(
			distance_to_light,
			1.0 - distance_to_light
		);

		float moving_light = 1.0 - smoothstep(
			0.0,
			light_length,
			distance_to_light
		);

		vec4 final_color = mix(
			base_glow_color,
			moving_light_color,
			moving_light
		);

		COLOR = final_color;
		COLOR.a = border * final_color.a;
	}
	"""

	var glow_material := ShaderMaterial.new()
	glow_material.shader = glow_shader

	second_panel_glow.material = glow_material

	# Keep the traveling light behind the panel's existing children.
	second_panel.add_child(second_panel_glow)

	second_panel.move_child(
		second_panel_glow,
		0
	)

	second_panel_glow.hide()


# =========================================================
# CONTINUE BUTTON STYLE
# =========================================================

func setup_continue_button():
	# Keep the button's text, size, and position from the editor.

	# NORMAL STYLE
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color("#702F46")
	normal_style.border_color = Color("#B99A68")
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(8)
	normal_style.shadow_color = Color(0.18, 0.04, 0.09, 0.45)
	normal_style.shadow_size = 4
	normal_style.shadow_offset = Vector2(0, 3)

	# HOVER STYLE
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color("#91445D")
	hover_style.border_color = Color("#E2C18A")
	hover_style.set_border_width_all(2)
	hover_style.set_corner_radius_all(8)
	hover_style.shadow_color = Color(0.18, 0.04, 0.09, 0.5)
	hover_style.shadow_size = 6
	hover_style.shadow_offset = Vector2(0, 3)

	# PRESSED STYLE
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color("#542235")
	pressed_style.border_color = Color("#A88758")
	pressed_style.set_border_width_all(2)
	pressed_style.set_corner_radius_all(8)
	pressed_style.shadow_color = Color(0.18, 0.04, 0.09, 0.35)
	pressed_style.shadow_size = 1
	pressed_style.shadow_offset = Vector2(0, 1)

	# APPLY STYLES
	continue_button.add_theme_stylebox_override("normal", normal_style)
	continue_button.add_theme_stylebox_override("hover", hover_style)
	continue_button.add_theme_stylebox_override("pressed", pressed_style)

	# TEXT COLORS
	continue_button.add_theme_color_override("font_color", Color("#F2E8D8"))
	continue_button.add_theme_color_override("font_hover_color", Color("#FFF4D8"))
	continue_button.add_theme_color_override("font_pressed_color", Color("#D8C4A3"))

	# HIDE UNTIL THE INTRO REVEALS IT
	continue_button.hide()
	continue_button.modulate.a = 0.0

	# CONNECT BUTTON SIGNAL
	if not continue_button.pressed.is_connected(_on_continue_button_pressed):
		continue_button.pressed.connect(_on_continue_button_pressed)

	continue_button.mouse_entered.connect(func():
		print("BUTTON HOVERED")
	)

	continue_button.mouse_exited.connect(func():
		print("BUTTON HOVER EXITED")
	)


# =========================================================
# MAIN INTRO SEQUENCE
# =========================================================

func start_intro_sequence() -> void:

	if sequence_running:
		return

	sequence_running = true


	# =====================================================
	# 1. GEARS GLITCHING — NO UI
	# =====================================================

	await get_tree().create_timer(
		GEAR_GLITCH_WAIT
	).timeout


	# =====================================================
	# 2. FIRST INSTRUCTION + DIM
	# =====================================================

	first_panel.show()

	first_panel.modulate.a = 0.0

	first_label.visible_characters = 0

	dim_overlay.show()
	dim_overlay.modulate.a = 0.0


	var first_appear_tween := create_tween()

	first_appear_tween.set_parallel(true)

	first_appear_tween.tween_property(
		dim_overlay,
		"modulate:a",
		1.0,
		FIRST_PANEL_FADE_TIME
	)

	first_appear_tween.tween_property(
		first_panel,
		"modulate:a",
		1.0,
		FIRST_PANEL_FADE_TIME
	)

	await first_appear_tween.finished


	# TYPE FIRST INSTRUCTION
	await type_label(first_label)


	await get_tree().create_timer(
		FIRST_PANEL_HOLD
	).timeout


	# =====================================================
	# 3. FIRST PANEL FADE OUT
	# =====================================================

	var first_disappear_tween := create_tween()

	first_disappear_tween.set_parallel(true)

	first_disappear_tween.tween_property(
		first_panel,
		"modulate:a",
		0.0,
		FIRST_PANEL_FADE_TIME
	)

	first_disappear_tween.tween_property(
		dim_overlay,
		"modulate:a",
		0.0,
		FIRST_PANEL_FADE_TIME
	)

	await first_disappear_tween.finished


	first_panel.hide()
	dim_overlay.hide()


	await get_tree().create_timer(
		BETWEEN_PANELS_WAIT
	).timeout


	# =====================================================
	# 4. SECOND INSTRUCTION + DIM
	# =====================================================

	second_panel.show()
	second_panel.modulate.a = 0.0

	second_heading.modulate.a = 0.0
	second_label.visible_characters = 0

	second_panel_glow.show()

	dim_overlay.show()
	dim_overlay.modulate.a = 0.0


	var second_appear_tween := create_tween()

	second_appear_tween.set_parallel(true)

	second_appear_tween.tween_property(
		dim_overlay,
		"modulate:a",
		1.0,
		SECOND_PANEL_FADE_TIME
	)

	second_appear_tween.tween_property(
		second_panel,
		"modulate:a",
		1.0,
		SECOND_PANEL_FADE_TIME
	)

	await second_appear_tween.finished


	# =====================================================
	# 5. HEADING APPEARS
	# =====================================================

	var heading_tween := create_tween()

	heading_tween.tween_property(
		second_heading,
		"modulate:a",
		1.0,
		0.5
	)

	await heading_tween.finished


	# =====================================================
	# 6. TYPE EXISTING INSTRUCTION TEXT
	# =====================================================

	await type_instruction_text()


	await get_tree().create_timer(
		SECOND_PANEL_HOLD_AFTER_TYPING
	).timeout


	# =====================================================
	# 7. MISSING GEAR GLOW APPEARS — STILL DIMMED
	# =====================================================

	missing_gear_glow.show()


	await get_tree().create_timer(
		MISSING_GEAR_GLOW_HOLD
	).timeout


	# =====================================================
	# 8. DIM OVERLAY DISAPPEARS
	# =====================================================

	var restore_tween := create_tween()

	restore_tween.tween_property(
		dim_overlay,
		"modulate:a",
		0.0,
		0.8
	)

	await restore_tween.finished

	dim_overlay.hide()


	# =====================================================
	# 9. CONTINUE BUTTON APPEARS
	# =====================================================

	continue_button.show()
	continue_button.modulate.a = 0.0


	var button_tween := create_tween()

	button_tween.tween_property(
		continue_button,
		"modulate:a",
		1.0,
		BUTTON_FADE_TIME
	)

	await button_tween.finished


	sequence_running = false


# =========================================================
# TYPEWRITER EFFECT — FIRST INSTRUCTION LABEL
# =========================================================

func type_label(label: Label) -> void:

	label.visible_characters = 0

	var total_characters := label.get_total_character_count()

	for character_index in range(total_characters):

		label.visible_characters = character_index + 1

		await get_tree().create_timer(
			TYPE_SPEED
		).timeout

	label.visible_characters = -1


# =========================================================
# TYPEWRITER EFFECT — SECOND INSTRUCTION TEXT
# =========================================================

func type_instruction_text() -> void:

	second_label.visible_characters = 0

	var total_characters := second_label.get_total_character_count()

	for character_index in range(total_characters):

		second_label.visible_characters = character_index + 1

		await get_tree().create_timer(
			TYPE_SPEED
		).timeout


	second_label.visible_characters = -1


# =========================================================
# CONTINUE BUTTON — TEST ONLY
# =========================================================

func _on_continue_button_pressed() -> void:

	print(
		"Continue button pressed — hospital transition not connected yet."
	)
