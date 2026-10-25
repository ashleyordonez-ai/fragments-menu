
extends Control

# ==================================================
# NODE REFERENCES
# ==================================================

@onready var diary_label: Label = $diary
@onready var missing_line: TextureRect = $"missing line"

@onready var decode_title: CanvasItem = $decode
@onready var decode_underline: CanvasItem = $"line under dec"
@onready var binary_clue: CanvasItem = $code
@onready var binary_glow_border: Panel = $BinaryGlowBorder

@onready var ascii_guide_box: CanvasItem = $"ASCII Guide Box"
@onready var ascii_guide_title: CanvasItem = $"ASCII guide"
@onready var ascii_guide_underline: CanvasItem = $"line under ascii guide"
@onready var titles: CanvasItem = $titles
@onready var letter_labels: CanvasItem = $letter
@onready var binary_labels: CanvasItem = $binary

@onready var answer_input: LineEdit = $AnswerInput
@onready var decode_button: Button = $DecodeButton
@onready var result_label: Label = $ResultLabel

@onready var view_more_button: Button = $ViewMoreButton
@onready var guide_popup: Control = $"PopOut Guide"
@onready var close_guide_button: Button = $"PopOut Guide/CloseButton"
@onready var focus_overlay: ColorRect = $FocusOverlay

# GREEN HINT POP-UP
@onready var hint_panel: PanelContainer = $HintPanel
@onready var hint_title: Label = $HintPanel/VBoxContainer/HintTitle
@onready var hint_label: Label = $HintPanel/VBoxContainer/HintLabel


# ==================================================
# SETTINGS
# ==================================================

const CORRECT_ANSWER := "BRIGHTER"

const TEXT_COLOR := Color("#4A2D22")
const PLACEHOLDER_COLOR := Color("#92745F")
const AMBER_COLOR := Color("#F2A65A")
const BORDER_COLOR := Color("#FFD08A")
const NORMAL_BORDER_COLOR := Color("#211711")
const ERROR_COLOR := Color("#D85C50")
const SUCCESS_COLOR := Color("#8BCB91")

const OVERLAY_COLOR := Color(0.08, 0.05, 0.04, 0.45)

# HINT PANEL COLORS
const HINT_GREEN := Color("#B7D5A8")
const HINT_GREEN_BORDER := Color("#52784B")
const HINT_TEXT_COLOR := Color("#263B25")

const TYPEWRITER_SPEED := 0.055
const SUCCESS_DISPLAY_TIME := 1.2


# ==================================================
# VARIABLES
# ==================================================

var diary_full_text: String = ""
var diary_intro_finished: bool = false
var puzzle_completed: bool = false
var success_animation_running: bool = false

var revealed_answer_label: Label

var popup_glow_style: StyleBoxFlat
var binary_glow_style: StyleBoxFlat
var hint_panel_style: StyleBoxFlat

var animation_time: float = 0.0
var binary_glow_time: float = 0.0
var hint_glow_time: float = 0.0

var binary_glow_active: bool = false
var hint_glow_active: bool = false

var popup_tween: Tween
var success_tween: Tween
var flash_tween: Tween

var right_page_elements: Array[CanvasItem] = []

# HINTS
var current_hint: int = 0

var hint_messages: Array[String] = [
	"Every 8 binary digits represent one letter.",
	"Match each binary group to its ASCII character.",
	"Read the decoded letters from left to right."
]


# ==================================================
# READY
# ==================================================

func _ready() -> void:
	diary_full_text = diary_label.text
	diary_label.visible_characters = 0

	missing_line.hide()

	right_page_elements = [
		decode_title,
		decode_underline,
		binary_clue,
		binary_glow_border,
		ascii_guide_box,
		ascii_guide_title,
		ascii_guide_underline,
		titles,
		letter_labels,
		binary_labels,
		answer_input,
		decode_button,
		result_label,
		view_more_button
	]

	set_right_page_visible(false)

	result_label.hide()
	guide_popup.hide()
	focus_overlay.hide()
	hint_panel.hide()

	focus_overlay.color = OVERLAY_COLOR
	focus_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	guide_popup.modulate.a = 1.0

	answer_input.add_theme_color_override(
		"font_color",
		TEXT_COLOR
	)

	answer_input.add_theme_color_override(
		"font_placeholder_color",
		PLACEHOLDER_COLOR
	)

	keep_ui_bright()
	setup_binary_glow()
	create_popup_glow_border()
	style_view_more_button()
	setup_bright_answer_controls()
	setup_hint_panel()

	if not view_more_button.pressed.is_connected(
		_on_view_more_button_pressed
	):
		view_more_button.pressed.connect(
			_on_view_more_button_pressed
		)

	if not close_guide_button.pressed.is_connected(
		_on_close_guide_button_pressed
	):
		close_guide_button.pressed.connect(
			_on_close_guide_button_pressed
		)

	if not decode_button.pressed.is_connected(check_answer):
		decode_button.pressed.connect(check_answer)

	if not answer_input.text_submitted.is_connected(
		_on_answer_submitted
	):
		answer_input.text_submitted.connect(
			_on_answer_submitted
		)

	play_diary_intro()


# ==================================================
# KEEP IMPORTANT UI ABOVE THE DIM OVERLAY
# ==================================================

func keep_ui_bright() -> void:
	guide_popup.z_as_relative = false
	guide_popup.z_index = 102

	binary_clue.z_as_relative = false
	binary_clue.z_index = 101

	binary_glow_border.z_as_relative = false
	binary_glow_border.z_index = 101

	answer_input.z_as_relative = false
	answer_input.z_index = 101

	decode_button.z_as_relative = false
	decode_button.z_index = 101

	view_more_button.z_as_relative = false
	view_more_button.z_index = 101

	hint_panel.z_as_relative = false
	hint_panel.z_index = 101


# ==================================================
# ANSWER CONTROLS — NO NEW BORDER GLOW
# ==================================================

func setup_bright_answer_controls() -> void:
	answer_input.modulate = Color.WHITE
	decode_button.modulate = Color.WHITE


# ==================================================
# VIEW MORE BUTTON STYLE
# ==================================================

func style_view_more_button() -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color("#AD5A4D")
	normal_style.set_corner_radius_all(5)

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color("#C16A59")
	hover_style.set_corner_radius_all(5)

	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color("#91483F")
	pressed_style.set_corner_radius_all(5)

	view_more_button.add_theme_stylebox_override(
		"normal",
		normal_style
	)

	view_more_button.add_theme_stylebox_override(
		"hover",
		hover_style
	)

	view_more_button.add_theme_stylebox_override(
		"pressed",
		pressed_style
	)


# ==================================================
# GREEN HINT PANEL STYLE
# ==================================================

func setup_hint_panel() -> void:
	hint_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	# Keep the panel's position and size from the Inspector.
	# Do not override its size or custom minimum size.

	hint_panel_style = StyleBoxFlat.new()
	hint_panel_style.bg_color = HINT_GREEN
	hint_panel_style.border_color = HINT_GREEN_BORDER
	hint_panel_style.set_border_width_all(2)
	hint_panel_style.set_corner_radius_all(8)

	# Compact padding, especially underneath the hint text.
	hint_panel_style.content_margin_left = 8.0
	hint_panel_style.content_margin_right = 8.0
	hint_panel_style.content_margin_top = 5.0
	hint_panel_style.content_margin_bottom = 1.0

	# Start without a glow; the glow activates when opened.
	hint_panel_style.shadow_color = Color("#F2A65A", 0.0)
	hint_panel_style.shadow_size = 0
	hint_panel_style.shadow_offset = Vector2.ZERO

	hint_panel.add_theme_stylebox_override(
		"panel",
		hint_panel_style
	)

	hint_title.add_theme_color_override(
		"font_color",
		HINT_TEXT_COLOR
	)

	hint_label.add_theme_color_override(
		"font_color",
		HINT_TEXT_COLOR
	)

	hint_title.text = "HINT"
	hint_label.text = hint_messages[0]

	var hint_container: VBoxContainer = $HintPanel/VBoxContainer
	hint_container.add_theme_constant_override("separation", 0)


# ==================================================
# DISPLAY CURRENT HINT
# ==================================================

func display_current_hint() -> void:
	if hint_messages.is_empty():
		return

	current_hint = clampi(
		current_hint,
		0,
		hint_messages.size() - 1
	)

	hint_title.text = "HINT %02d" % (current_hint + 1)
	hint_label.text = hint_messages[current_hint]


# ==================================================
# SHOW NEXT HINT AFTER AN INCORRECT ANSWER
# ==================================================

func show_next_hint() -> void:
	if hint_messages.is_empty():
		return

	current_hint = mini(
		current_hint + 1,
		hint_messages.size() - 1
	)

	display_current_hint()


# ==================================================
# RIGHT PAGE VISIBILITY
# ==================================================

func set_right_page_visible(is_visible: bool) -> void:
	for element in right_page_elements:
		if is_instance_valid(element):
			element.visible = is_visible


# ==================================================
# DIARY TYPEWRITER INTRO
# ==================================================

func play_diary_intro() -> void:
	diary_intro_finished = false
	diary_label.visible_characters = 0

	await get_tree().process_frame

	for character_index in range(diary_full_text.length()):
		if not is_instance_valid(diary_label):
			return

		diary_label.visible_characters = character_index + 1

		await get_tree().create_timer(
			TYPEWRITER_SPEED
		).timeout

	diary_label.visible_characters = -1
	diary_intro_finished = true

	missing_line.show()
	set_right_page_visible(true)

	view_more_button.show()


# ==================================================
# VIEW MORE — OPEN GUIDE AND GREEN HINT PANEL
# ==================================================

func _on_view_more_button_pressed() -> void:
	if puzzle_completed:
		return

	focus_overlay.color = OVERLAY_COLOR
	focus_overlay.show()

	focus_overlay.z_as_relative = false
	focus_overlay.z_index = 100

	keep_ui_bright()

	# Open the existing ASCII Guide pop-up.
	guide_popup.show()
	guide_popup.modulate.a = 0.0

	if popup_tween and popup_tween.is_running():
		popup_tween.kill()

	popup_tween = create_tween()
	popup_tween.tween_property(
		guide_popup,
		"modulate:a",
		1.0,
		0.2
	)

	# Show the green hint panel.
	display_current_hint()
	hint_panel.show()

	# Start the hint panel's amber border glow.
	hint_glow_active = true
	hint_glow_time = 0.0

	# Animate only the binary panel border.
	binary_glow_active = true
	binary_glow_time = 0.0

	# Change binary text color without animating it.
	set_binary_text_color(Color("#FFF0CF"))


# ==================================================
# CLOSE GUIDE AND GREEN HINT PANEL
# ==================================================

func _on_close_guide_button_pressed() -> void:
	guide_popup.hide()
	guide_popup.modulate.a = 1.0

	hint_panel.hide()
	hint_glow_active = false
	hint_glow_time = 0.0

	if hint_panel_style != null:
		hint_panel_style.border_color = HINT_GREEN_BORDER
		hint_panel_style.shadow_color = Color("#F2A65A", 0.0)
		hint_panel_style.shadow_size = 0

	focus_overlay.hide()

	stop_binary_glow()

	set_binary_text_color(Color("#211710"))

	if not puzzle_completed:
		answer_input.grab_focus()


# ==================================================
# SET BINARY TEXT COLOR WITHOUT BLINKING
# ==================================================

func set_binary_text_color(new_color: Color) -> void:
	_apply_binary_text_color(binary_clue, new_color)


func _apply_binary_text_color(node: Node, new_color: Color) -> void:
	if node is Label:
		var current_label := node as Label

		current_label.add_theme_color_override(
			"font_color",
			new_color
		)

	for child in node.get_children():
		_apply_binary_text_color(child, new_color)


# ==================================================
# BINARY PANEL — TRANSPARENT CENTER
# ==================================================

func setup_binary_glow() -> void:
	binary_glow_border.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var original_style: StyleBox = (
		binary_glow_border.get_theme_stylebox("panel")
	)

	if original_style is StyleBoxFlat:
		binary_glow_style = (
			original_style as StyleBoxFlat
		).duplicate() as StyleBoxFlat
	else:
		binary_glow_style = StyleBoxFlat.new()

	binary_glow_style.bg_color = Color(0, 0, 0, 0)
	binary_glow_style.set_border_width_all(2)
	binary_glow_style.set_corner_radius_all(6)

	binary_glow_style.border_color = NORMAL_BORDER_COLOR
	binary_glow_style.shadow_color = Color("#F2A65A", 0.0)
	binary_glow_style.shadow_size = 0
	binary_glow_style.shadow_offset = Vector2.ZERO

	binary_glow_border.add_theme_stylebox_override(
		"panel",
		binary_glow_style
	)


# ==================================================
# EXISTING ASCII GUIDE BORDER
# ==================================================

func create_popup_glow_border() -> void:
	var existing_border: Node = guide_popup.get_node_or_null(
		"AnimatedGlowBorder"
	)

	if existing_border is Panel:
		var existing_panel := existing_border as Panel
		var existing_style: StyleBox = (
			existing_panel.get_theme_stylebox("panel")
		)

		if existing_style is StyleBoxFlat:
			popup_glow_style = (
				existing_style as StyleBoxFlat
			).duplicate() as StyleBoxFlat

		if popup_glow_style != null:
			existing_panel.add_theme_stylebox_override(
				"panel",
				popup_glow_style
			)

		return

	var glow_border := Panel.new()
	glow_border.name = "AnimatedGlowBorder"
	glow_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow_border.set_anchors_preset(Control.PRESET_FULL_RECT)

	glow_border.offset_left = -3
	glow_border.offset_top = -3
	glow_border.offset_right = 3
	glow_border.offset_bottom = 3
	glow_border.z_index = -1

	popup_glow_style = StyleBoxFlat.new()
	popup_glow_style.bg_color = Color(0, 0, 0, 0)

	popup_glow_style.set_border_width_all(3)
	popup_glow_style.set_corner_radius_all(9)

	popup_glow_style.border_color = AMBER_COLOR
	popup_glow_style.shadow_color = Color("#F2A65A", 0.8)
	popup_glow_style.shadow_size = 12
	popup_glow_style.shadow_offset = Vector2.ZERO

	glow_border.add_theme_stylebox_override(
		"panel",
		popup_glow_style
	)

	guide_popup.add_child(glow_border)
	guide_popup.move_child(glow_border, 0)


# ==================================================
# ANIMATE BORDER GLOWS — NEVER ANIMATE TEXT
# ==================================================

func _process(delta: float) -> void:
	animation_time += delta

	var wave: float = (
		sin(animation_time * 2.5) + 1.0
	) / 2.0

	# Existing ASCII Guide border animation.
	if guide_popup.visible and popup_glow_style != null:
		popup_glow_style.border_color = Color(
			1.0,
			0.65 + wave * 0.25,
			0.30 + wave * 0.20,
			1.0
		)

		popup_glow_style.shadow_color = Color(
			"#F2A65A",
			0.60 + wave * 0.35
		)

		popup_glow_style.shadow_size = int(
			8 + wave * 8
		)

	# Green hint panel border glow.
	# This runs before the binary-glow check so both can work independently.
	if hint_glow_active and hint_panel.visible and hint_panel_style != null:
		hint_glow_time += delta

		var hint_wave: float = (
			sin(hint_glow_time * 2.5) + 1.0
		) / 2.0

		hint_panel_style.border_color = Color(
			0.95,
			0.72 + hint_wave * 0.20,
			0.40 + hint_wave * 0.20,
			1.0
		)

		hint_panel_style.shadow_color = Color(
			"#F2A65A",
			0.35 + hint_wave * 0.45
		)

		hint_panel_style.shadow_size = int(
			4 + hint_wave * 7
		)

	# Binary panel border animation only.
	if not binary_glow_active:
		return

	binary_glow_time += delta

	var binary_wave: float = (
		sin(binary_glow_time * 2.5) + 1.0
	) / 2.0

	binary_glow_style.border_color = Color(
		1.0,
		0.62 + binary_wave * 0.25,
		0.28 + binary_wave * 0.18,
		1.0
	)

	binary_glow_style.shadow_color = Color(
		"#F2A65A",
		0.20 + binary_wave * 0.35
	)

	binary_glow_style.shadow_size = int(
		3 + binary_wave * 5
	)


# ==================================================
# STOP BINARY PANEL BORDER GLOW
# ==================================================

func stop_binary_glow() -> void:
	binary_glow_active = false
	binary_glow_time = 0.0

	if binary_glow_style != null:
		binary_glow_style.bg_color = Color(0, 0, 0, 0)
		binary_glow_style.border_color = NORMAL_BORDER_COLOR
		binary_glow_style.shadow_color = Color("#F2A65A", 0.0)
		binary_glow_style.shadow_size = 0
		binary_glow_style.shadow_offset = Vector2.ZERO


# ==================================================
# ANSWER SUBMITTED
# ==================================================

func _on_answer_submitted(_submitted_text: String) -> void:
	check_answer()


# ==================================================
# CHECK ANSWER
# ==================================================

func check_answer() -> void:
	if puzzle_completed or success_animation_running:
		return

	var submitted_answer: String = (
		answer_input.text.strip_edges().to_upper()
	)

	if submitted_answer.is_empty():
		show_result(
			"Please enter your decoded word.",
			AMBER_COLOR
		)
		return

	if submitted_answer == CORRECT_ANSWER:
		show_correct_answer()
	else:
		show_result(
			"Not quite. Try decoding the binary again.",
			ERROR_COLOR
		)

		shake_answer_input()
		show_next_hint()


# ==================================================
# RESULT MESSAGE
# ==================================================

func show_result(message: String, message_color: Color) -> void:
	result_label.text = message

	result_label.add_theme_color_override(
		"font_color",
		message_color
	)

	result_label.show()


# ==================================================
# SHAKE INPUT ON WRONG ANSWER
# ==================================================

func shake_answer_input() -> void:
	var original_position: Vector2 = answer_input.position

	var shake_tween := create_tween()

	shake_tween.tween_property(
		answer_input,
		"position",
		original_position + Vector2(-5, 0),
		0.04
	)

	shake_tween.tween_property(
		answer_input,
		"position",
		original_position + Vector2(5, 0),
		0.04
	)

	shake_tween.tween_property(
		answer_input,
		"position",
		original_position + Vector2(-3, 0),
		0.04
	)

	shake_tween.tween_property(
		answer_input,
		"position",
		original_position,
		0.04
	)


# ==================================================
# GREEN FLASH ON CORRECT ANSWER
# ==================================================

func play_answer_flash() -> void:
	if flash_tween and flash_tween.is_running():
		flash_tween.kill()

	answer_input.modulate = Color.WHITE

	flash_tween = create_tween()

	flash_tween.tween_property(
		answer_input,
		"modulate",
		Color(0.55, 1.0, 0.55, 1.0),
		0.12
	)

	flash_tween.tween_property(
		answer_input,
		"modulate",
		Color.WHITE,
		0.35
	)


# ==================================================
# CORRECT ANSWER
# ==================================================

func show_correct_answer() -> void:
	if success_animation_running:
		return

	success_animation_running = true
	puzzle_completed = true

	answer_input.editable = false
	decode_button.disabled = true

	show_result(
		"Correct! You found the word.",
		SUCCESS_COLOR
	)

	play_answer_flash()

	# Briefly highlight the binary panel border.
	binary_glow_active = true
	binary_glow_time = 0.0

	await get_tree().create_timer(
		SUCCESS_DISPLAY_TIME
	).timeout

	reveal_diary_answer()
	
	set_right_page_visible(false)

	answer_input.hide()
	decode_button.hide()
	result_label.hide()
	view_more_button.hide()

	guide_popup.hide()
	hint_panel.hide()
	hint_glow_active = false
	hint_glow_time = 0.0

	if hint_panel_style != null:
		hint_panel_style.border_color = HINT_GREEN_BORDER
		hint_panel_style.shadow_color = Color("#F2A65A", 0.0)
		hint_panel_style.shadow_size = 0

	focus_overlay.hide()

	stop_binary_glow()
	set_binary_text_color(Color("#211710"))

	success_animation_running = false


# ==================================================
# REVEAL "brighter" IN THE DIARY
# ==================================================

func reveal_diary_answer() -> void:
	missing_line.hide()

	if is_instance_valid(revealed_answer_label):
		revealed_answer_label.queue_free()

	revealed_answer_label = Label.new()
	revealed_answer_label.name = "RevealedAnswer"
	revealed_answer_label.text = "brighter"

	revealed_answer_label.position = (
		missing_line.position - Vector2(0, 23)
	)

	revealed_answer_label.size = Vector2(
		maxf(missing_line.size.x, 150.0),
		40
	)

	revealed_answer_label.rotation_degrees = -5.0

	revealed_answer_label.add_theme_color_override(
		"font_color",
		TEXT_COLOR
	)

	var diary_font: Font = diary_label.get_theme_font("font")

	if diary_font != null:
		revealed_answer_label.add_theme_font_override(
			"font",
			diary_font
		)

	revealed_answer_label.add_theme_font_size_override(
		"font_size",
		diary_label.get_theme_font_size("font_size")
	)

	add_child(revealed_answer_label)

	revealed_answer_label.scale = Vector2(0.8, 0.8)
	revealed_answer_label.pivot_offset = (
		revealed_answer_label.size / 2.0
	)

	var reveal_tween := create_tween()

	reveal_tween.set_trans(Tween.TRANS_BACK)
	reveal_tween.set_ease(Tween.EASE_OUT)

	reveal_tween.tween_property(
		revealed_answer_label,
		"scale",
		Vector2.ONE,
		0.3
	)
