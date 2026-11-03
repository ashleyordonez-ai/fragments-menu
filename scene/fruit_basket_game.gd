
extends Control

const STARTING_ATTEMPTS: int = 3

const ATTEMPTS_BORDER_DIM: Color = Color("#8F3948")
const ATTEMPTS_BORDER_BRIGHT: Color = Color("#F2A0AA")
const ATTEMPTS_BORDER_GLOW: Color = Color("#D94B60")

const RESULT_WRONG_BG: Color = Color("#A52D3B")
const RESULT_WRONG_TEXT: Color = Color("#FFFFFF")
const RESULT_WRONG_GLOW: Color = Color("#FF3434")

const RESULT_CORRECT_BG: Color = Color("#23734B")
const RESULT_CORRECT_TEXT: Color = Color("#FFFFFF")
const RESULT_CORRECT_GLOW: Color = Color("#38FF83")

const INSTRUCTION_DIM_ALPHA: float = 0.25

var attempts_left: int = STARTING_ATTEMPTS
var selected_fruits: Array[String] = []
var fruit_original_positions: Dictionary = {}
var fruit_tweens: Dictionary = {}

var selected_fruit: TextureButton = null
var game_won: bool = false

var attempts_glow_tween: Tween
var attempts_border: Line2D
var attempts_glow_border: Line2D
var attempts_border_progress: float = 0.0

var instruction_original_modulate: Color = Color.WHITE
var instruction_original_glow_modulate: Color = Color.WHITE
var instruction_original_position: Vector2

var result_effect_tween: Tween
var result_glitch_tween: Tween
var result_original_position: Vector2
var result_original_scale: Vector2 = Vector2.ONE
var result_original_modulate: Color = Color.WHITE
var result_original_label_modulate: Color = Color.WHITE

# Green flash effect only.
var green_flash: ColorRect
var green_flash_tween: Tween


# ==========================================
# MAIN NODES
# ==========================================

@onready var basket_intro: Control = $BasketIntro
@onready var puzzle_area: Control = $PuzzleArea

@onready var attempts_panel: Panel = $AttemptsPanel
@onready var attempts_label: Label = $AttemptsPanel/AttemptsLabel

@onready var instruction_label: Label = $PuzzleArea/InstructionLabel
@onready var instruction_glow: Control = $PuzzleArea/InstructionGlow
@onready var instruction_panel: Control = $PuzzleArea/InstructionPanel
@onready var fruit_panel: Control = $PuzzleArea/FruitPanel
@onready var fruit_container: Control = $PuzzleArea/FruitContainer

@onready var riddle_panel: Control = $PuzzleArea/RiddlePanel
@onready var riddle_text: Label = $PuzzleArea/RiddlePanel/RiddleText

@onready var background_dimmer: ColorRect = $BackgroundDimmer


# ==========================================
# SCRATCH POPUP NODES
# ==========================================

@onready var scratch_popup: Panel = $ScratchPopup
@onready var scratch_title: Label = $ScratchPopup/ScratchTitle
@onready var gear_image: TextureRect = $ScratchPopup/GearImage
@onready var fruit_to_scratch: TextureRect = $ScratchPopup/FruitToScratch
@onready var result_label: Label = $ScratchPopup/ResultLabel
@onready var scratch_cover: ColorRect = $ScratchPopup/ScratchCover
@onready var close_button: Button = $ScratchPopup/CloseButton

@onready var hidden_message: Label = $ScratchPopup/HiddenMeessage


# ==========================================
# RESULT NOTIFICATION
# ==========================================

@onready var result_notification: Panel = $ResultNotification
@onready var notification_label: Label = $ResultNotification/NotificationLabel


# ==========================================
# FRUIT BUTTONS
# ==========================================

@onready var fruits: Array[TextureButton] = [
	$PuzzleArea/FruitContainer/Apple,
	$PuzzleArea/FruitContainer/Orange,
	$PuzzleArea/FruitContainer/Banana,
	$PuzzleArea/FruitContainer/Strawberry,
	$PuzzleArea/FruitContainer/Pear,
	$PuzzleArea/FruitContainer/Grapes
]


# ==========================================
# INITIALIZE
# ==========================================

func _ready() -> void:
	background_dimmer.hide()
	scratch_popup.hide()
	gear_image.hide()
	result_label.hide()
	result_notification.hide()
	attempts_panel.hide()

	style_close_button()

	# Create full-screen green flash overlay.
	green_flash = ColorRect.new()
	green_flash.name = "GreenFlash"
	green_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	green_flash.color = Color(0.2, 1.0, 0.45, 0.0)
	green_flash.modulate = Color.WHITE
	green_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	green_flash.z_index = 90


	add_child(green_flash)

	# Keep the overlay invisible at the beginning.
	green_flash.color.a = 0.0
	green_flash.hide()

	instruction_label.text = (
		"Choose a fruit to scratch and discover what's hidden inside!"
	)

	# Keep the scratch title centered for every message.
	scratch_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scratch_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	instruction_original_position = instruction_panel.position
	instruction_original_modulate = instruction_panel.modulate
	instruction_original_glow_modulate = instruction_glow.modulate

	fruit_to_scratch.set_anchors_preset(Control.PRESET_TOP_LEFT)
	fruit_to_scratch.size = Vector2(400, 300)
	fruit_to_scratch.position = (
		scratch_popup.size - fruit_to_scratch.size
	) / 2.0

	fruit_to_scratch.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fruit_to_scratch.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# Keep the hidden message above the popup background,
	# but behind the fruit image.
	hidden_message.z_index = 1
	fruit_to_scratch.z_index = 2

	notification_label.add_theme_color_override(
		"font_color",
		Color.WHITE
	)
	notification_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	result_original_position = result_notification.position
	result_original_scale = result_notification.scale
	result_original_modulate = result_notification.modulate
	result_original_label_modulate = notification_label.modulate

	# Keep the result notification above the scratch popup.
	result_notification.z_index = 100
	result_notification.top_level = false

	for fruit in fruits:
		if not fruit.pressed.is_connected(_on_fruit_pressed.bind(fruit)):
			fruit.pressed.connect(_on_fruit_pressed.bind(fruit))

		fruit_original_positions[fruit] = fruit.position

		if not fruit.mouse_entered.is_connected(
			_on_fruit_mouse_entered.bind(fruit)
		):
			fruit.mouse_entered.connect(
				_on_fruit_mouse_entered.bind(fruit)
			)

		if not fruit.mouse_exited.is_connected(
			_on_fruit_mouse_exited.bind(fruit)
		):
			fruit.mouse_exited.connect(
				_on_fruit_mouse_exited.bind(fruit)
			)

	if not scratch_cover.scratch_completed.is_connected(
		_on_scratch_completed
	):
		scratch_cover.scratch_completed.connect(
			_on_scratch_completed
		)

	if not close_button.pressed.is_connected(
		_on_close_button_pressed
	):
		close_button.pressed.connect(
			_on_close_button_pressed
		)

	scratch_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scratch_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	scratch_title.position.y -= 8.0

	update_attempts_label()
	start_intro_sequence()


# ==========================================
# CLOSE BUTTON STYLE
# Muted red, centered text, clickable feedback.
# ==========================================

func style_close_button() -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color("#754650")
	normal_style.border_color = Color("#D18B96")
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(10)
	normal_style.content_margin_left = 16
	normal_style.content_margin_right = 16
	normal_style.content_margin_top = 8
	normal_style.content_margin_bottom = 8
	normal_style.shadow_color = Color("#2B1018")
	normal_style.shadow_color.a = 0.45
	normal_style.shadow_size = 4
	normal_style.shadow_offset = Vector2(0, 2)

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color("#925966")
	hover_style.border_color = Color("#F0B2BB")
	hover_style.set_border_width_all(2)
	hover_style.set_corner_radius_all(10)
	hover_style.content_margin_left = 16
	hover_style.content_margin_right = 16
	hover_style.content_margin_top = 8
	hover_style.content_margin_bottom = 8
	hover_style.shadow_color = Color("#3B1721")
	hover_style.shadow_color.a = 0.6
	hover_style.shadow_size = 7
	hover_style.shadow_offset = Vector2(0, 3)

	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color("#593540")
	pressed_style.border_color = Color("#B87580")
	pressed_style.set_border_width_all(2)
	pressed_style.set_corner_radius_all(10)
	pressed_style.content_margin_left = 16
	pressed_style.content_margin_right = 16
	pressed_style.content_margin_top = 8
	pressed_style.content_margin_bottom = 8

	close_button.add_theme_stylebox_override("normal", normal_style)
	close_button.add_theme_stylebox_override("hover", hover_style)
	close_button.add_theme_stylebox_override("pressed", pressed_style)
	close_button.add_theme_stylebox_override("focus", hover_style)

	close_button.add_theme_color_override(
		"font_color",
		Color("#FFF1F2")
	)
	close_button.add_theme_color_override(
		"font_hover_color",
		Color.WHITE
	)
	close_button.add_theme_color_override(
		"font_pressed_color",
		Color("#F5DDE0")
	)

	close_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	close_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


# ==========================================
# ATTEMPTS PANEL BORDER GLOW
# ==========================================

func start_attempts_border_glow() -> void:
	if attempts_glow_tween and attempts_glow_tween.is_running():
		attempts_glow_tween.kill()

	if is_instance_valid(attempts_border):
		attempts_border.queue_free()

	if is_instance_valid(attempts_glow_border):
		attempts_glow_border.queue_free()

	attempts_border = Line2D.new()
	attempts_border.name = "AttemptsGoldBorder"
	attempts_border.width = 2.0
	attempts_border.default_color = ATTEMPTS_BORDER_BRIGHT
	attempts_border.antialiased = true
	attempts_border.closed = true
	attempts_border.z_index = 10
	attempts_border.position = Vector2.ZERO

	attempts_glow_border = Line2D.new()
	attempts_glow_border.name = "AttemptsGoldGlow"
	attempts_glow_border.width = 3.5
	attempts_glow_border.default_color = ATTEMPTS_BORDER_GLOW
	attempts_glow_border.default_color.a = 0.25
	attempts_glow_border.antialiased = true
	attempts_glow_border.closed = true
	attempts_glow_border.z_index = 9
	attempts_glow_border.position = Vector2.ZERO

	attempts_panel.add_child(attempts_glow_border)
	attempts_panel.add_child(attempts_border)

	_update_attempts_border_size()

	if not attempts_panel.resized.is_connected(
		_update_attempts_border_size
	):
		attempts_panel.resized.connect(
			_update_attempts_border_size
		)

	attempts_glow_tween = create_tween()
	attempts_glow_tween.set_loops()

	attempts_glow_tween.tween_method(
		_update_traveling_gold,
		0.0,
		1.0,
		1.8
	).set_trans(Tween.TRANS_LINEAR)


func _update_traveling_gold(progress: float) -> void:
	if not is_instance_valid(attempts_border):
		return

	if not is_instance_valid(attempts_glow_border):
		return

	attempts_border_progress = progress
	attempts_border.default_color = ATTEMPTS_BORDER_BRIGHT

	var pulse: float = (sin(progress * TAU * 2.0) + 1.0) / 2.0

	attempts_glow_border.default_color = ATTEMPTS_BORDER_GLOW
	attempts_glow_border.default_color.a = lerpf(
		0.15,
		0.45,
		pulse
	)

	_update_shining_segment(progress)


func _update_attempts_border_size() -> void:
	if not is_instance_valid(attempts_border):
		return

	var border_size: Vector2 = attempts_panel.size

	if border_size.x <= 4.0 or border_size.y <= 4.0:
		return

	var corners := PackedVector2Array([
		Vector2(2.0, 2.0),
		Vector2(border_size.x - 2.0, 2.0),
		Vector2(border_size.x - 2.0, border_size.y - 2.0),
		Vector2(2.0, border_size.y - 2.0)
	])

	attempts_border.points = corners

	if is_instance_valid(attempts_glow_border):
		attempts_glow_border.points = corners


func _update_shining_segment(progress: float) -> void:
	if not is_instance_valid(attempts_border):
		return

	var size: Vector2 = attempts_panel.size

	var left: float = 2.0
	var top: float = 2.0
	var right: float = size.x - 2.0
	var bottom: float = size.y - 2.0

	if right <= left or bottom <= top:
		return

	var perimeter: float = 2.0 * (
		(right - left) + (bottom - top)
	)

	var shine_length: float = perimeter * 0.22
	var shine_start: float = progress * perimeter

	var shine_points := PackedVector2Array()
	var samples: int = 36

	for i in range(samples + 1):
		var distance: float = fposmod(
			shine_start + shine_length * float(i) / samples,
			perimeter
		)

		var point: Vector2

		if distance < right - left:
			point = Vector2(left + distance, top)

		elif distance < (right - left) + (bottom - top):
			point = Vector2(
				right,
				top + distance - (right - left)
			)

		elif distance < 2.0 * (right - left) + (bottom - top):
			point = Vector2(
				right - (
					distance - (right - left) - (bottom - top)
				),
				bottom
			)

		else:
			point = Vector2(
				left,
				bottom - (
					distance - 2.0 * (right - left) - (bottom - top)
				)
			)

		shine_points.append(point)

	attempts_border.points = shine_points
	attempts_border.closed = false
	attempts_border.width = 2.5
	attempts_border.default_color = ATTEMPTS_BORDER_BRIGHT


# ==========================================
# RESULT NOTIFICATION
# Entire panel changes color.
# ==========================================

func show_result_effect(is_correct: bool) -> void:
	if result_effect_tween and result_effect_tween.is_running():
		result_effect_tween.kill()

	if result_glitch_tween and result_glitch_tween.is_running():
		result_glitch_tween.kill()

	var panel_color: Color
	var text_color: Color
	var glow_color: Color

	if is_correct:
		panel_color = RESULT_CORRECT_BG
		text_color = RESULT_CORRECT_TEXT
		glow_color = RESULT_CORRECT_GLOW
	else:
		panel_color = RESULT_WRONG_BG
		text_color = RESULT_WRONG_TEXT
		glow_color = RESULT_WRONG_GLOW

	var style := StyleBoxFlat.new()
	style.bg_color = panel_color
	style.set_border_width_all(0)
	style.set_corner_radius_all(12)

	style.shadow_color = glow_color
	style.shadow_color.a = 0.5
	style.shadow_size = 10
	style.shadow_offset = Vector2.ZERO

	result_notification.add_theme_stylebox_override("panel", style)

	notification_label.add_theme_color_override(
		"font_color",
		text_color
	)
	notification_label.modulate = Color.WHITE
	notification_label.show()
	notification_label.z_index = 5

	result_notification.show()
	result_notification.z_index = 100
	result_notification.move_to_front()

	result_notification.scale = result_original_scale * 0.96
	result_notification.pivot_offset = result_notification.size / 2.0

	result_effect_tween = create_tween()
	result_effect_tween.tween_property(
		result_notification,
		"scale",
		result_original_scale,
		0.18
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if not is_correct:
		play_result_glitch()


func play_result_glitch() -> void:
	if not is_instance_valid(result_notification):
		return

	if result_glitch_tween and result_glitch_tween.is_running():
		result_glitch_tween.kill()

	result_glitch_tween = create_tween()

	for i in range(8):
		var offset_x: float = randf_range(-4.0, 4.0)
		var offset_y: float = randf_range(-2.0, 2.0)

		result_glitch_tween.tween_property(
			result_notification,
			"position",
			result_original_position + Vector2(offset_x, offset_y),
			0.035
		)

	result_glitch_tween.tween_property(
		result_notification,
		"position",
		result_original_position,
		0.04
	)


func reset_result_notification() -> void:
	if result_effect_tween and result_effect_tween.is_running():
		result_effect_tween.kill()

	if result_glitch_tween and result_glitch_tween.is_running():
		result_glitch_tween.kill()

	result_notification.position = result_original_position
	result_notification.scale = result_original_scale
	result_notification.modulate = result_original_modulate
	result_notification.hide()

	if result_notification.has_theme_stylebox_override("panel"):
		result_notification.remove_theme_stylebox_override("panel")

	notification_label.remove_theme_color_override("font_color")
	notification_label.modulate = result_original_label_modulate
	notification_label.z_index = 0


# ==========================================
# FULL-SCREEN GREEN SUCCESS FLASH
# Loops only after successful Grapes scratching.
# ==========================================

func play_green_screen_flash() -> void:
	if green_flash_tween and green_flash_tween.is_running():
		return

	green_flash.color = Color(0.2, 1.0, 0.45, 0.0)
	green_flash.show()
	green_flash.move_to_front()

	green_flash_tween = create_tween()
	green_flash_tween.set_loops()

	green_flash_tween.tween_property(
		green_flash,
		"color:a",
		0.30,
		0.12
	)

	green_flash_tween.tween_property(
		green_flash,
		"color:a",
		0.0,
		0.16
	)


# ==========================================
# INSTRUCTION PANEL DIMMING
# ==========================================

func dim_instruction_panel() -> void:
	instruction_glow.hide()
	instruction_glow.modulate.a = 0.0

	instruction_panel.modulate.a = INSTRUCTION_DIM_ALPHA
	instruction_label.modulate.a = INSTRUCTION_DIM_ALPHA


func restore_instruction_panel() -> void:
	instruction_panel.modulate = instruction_original_modulate
	instruction_panel.position = instruction_original_position
	instruction_label.modulate = Color.WHITE

	instruction_glow.show()
	instruction_glow.modulate = instruction_original_glow_modulate


# ==========================================
# BASKET INTRO TRANSITION
# ==========================================

func start_intro_sequence() -> void:
	if not is_inside_tree():
		return

	basket_intro.show()
	puzzle_area.hide()

	var basket_image: TextureRect = $BasketIntro/BasketImage
	var viewport_size: Vector2 = get_viewport_rect().size

	basket_image.position = (
		viewport_size - basket_image.size
	) / 2.0

	basket_image.pivot_offset = basket_image.size / 2.0
	basket_image.scale = Vector2.ONE
	basket_image.modulate.a = 1.0

	await get_tree().create_timer(0.8).timeout

	if not is_inside_tree():
		return

	var zoom_tween: Tween = create_tween()
	zoom_tween.set_parallel(true)

	zoom_tween.tween_property(
		basket_image,
		"scale",
		Vector2(2.5, 2.5),
		0.9
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	zoom_tween.tween_property(
		basket_image,
		"modulate:a",
		0.0,
		0.9
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await zoom_tween.finished

	if not is_inside_tree():
		return

	basket_intro.hide()
	puzzle_area.show()

	await play_puzzle_reveal_sequence()


# ==========================================
# PUZZLE UI REVEAL SEQUENCE
# ==========================================

func play_puzzle_reveal_sequence() -> void:
	instruction_glow.hide()
	instruction_panel.hide()
	instruction_label.hide()
	riddle_panel.hide()
	fruit_panel.hide()
	fruit_container.hide()
	attempts_panel.hide()

	instruction_glow.modulate.a = 0.0
	instruction_panel.modulate.a = 0.0
	instruction_label.modulate.a = 0.0
	riddle_panel.modulate.a = 0.0
	fruit_panel.modulate.a = 0.0
	attempts_panel.modulate.a = 1.0

	instruction_glow.show()
	instruction_panel.show()
	instruction_label.show()

	instruction_panel.scale = Vector2(0.75, 0.75)
	instruction_panel.pivot_offset = instruction_panel.size / 2.0
	instruction_panel.modulate.a = 0.0

	instruction_glow.modulate.a = 0.0
	instruction_label.modulate.a = 0.0

	var instruction_tween: Tween = create_tween()
	instruction_tween.set_parallel(true)

	instruction_tween.tween_property(
		instruction_panel,
		"scale",
		Vector2.ONE,
		0.45
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	instruction_tween.tween_property(
		instruction_panel,
		"modulate:a",
		1.0,
		0.35
	)

	instruction_tween.tween_property(
		instruction_glow,
		"modulate:a",
		1.0,
		0.6
	)

	instruction_tween.tween_property(
		instruction_label,
		"modulate:a",
		1.0,
		0.45
	)

	await instruction_tween.finished

	riddle_text.hide()
	riddle_text.visible_characters = 0

	riddle_panel.modulate.a = 0.0
	riddle_panel.show()

	var riddle_panel_tween: Tween = create_tween()
	riddle_panel_tween.tween_property(
		riddle_panel,
		"modulate:a",
		1.0,
		0.5
	)

	await riddle_panel_tween.finished

	riddle_text.visible_characters = 0
	riddle_text.show()

	var full_text: String = riddle_text.text

	for character_index in range(full_text.length() + 1):
		if not is_inside_tree():
			return

		riddle_text.visible_characters = character_index
		await get_tree().create_timer(0.045).timeout

	attempts_panel.show()
	attempts_panel.modulate = Color.WHITE
	attempts_label.modulate = Color.WHITE
	start_attempts_border_glow()

	fruit_panel.show()

	var fruit_panel_tween: Tween = create_tween()
	fruit_panel_tween.tween_property(
		fruit_panel,
		"modulate:a",
		1.0,
		0.5
	)

	await fruit_panel_tween.finished

	fruit_container.show()
	start_scatter_animation()


# ==========================================
# FRUIT SCATTER ANIMATION
# ==========================================

func start_scatter_animation() -> void:
	var destinations: Array[Vector2] = []

	for fruit in fruits:
		destinations.append(fruit.position)

	for fruit in fruits:
		fruit.position = Vector2(550, 280)
		fruit.modulate.a = 0.0

	var tween: Tween = create_tween()
	tween.set_parallel(true)

	for i in range(fruits.size()):
		var fruit: TextureButton = fruits[i]

		tween.tween_property(
			fruit,
			"position",
			destinations[i],
			0.8
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		tween.tween_property(
			fruit,
			"modulate:a",
			1.0,
			0.6
		)


# ==========================================
# FRUIT CLICK: OPEN SCRATCH POPUP
# ==========================================

func _on_fruit_pressed(fruit: TextureButton) -> void:
	if attempts_left <= 0 or game_won:
		return

	if selected_fruit != null:
		return

	var fruit_name: String = str(fruit.name)

	if selected_fruits.has(fruit_name):
		return

	if fruit.name == "Banana":
		hidden_message.position = Vector2(78, 140)
	else:
		hidden_message.position = Vector2(78, 85)

	selected_fruit = fruit
	fruit_to_scratch.texture = fruit.texture_normal

	scratch_title.text = "SCRATCH THE FRUIT"

	result_label.hide()
	notification_label.text = ""
	reset_result_notification()

	# Show the correct hidden content underneath the fruit.
	if fruit_name == "Grapes":
		hidden_message.hide()
		gear_image.show()
	else:
		hidden_message.text = "NO GEAR HERE"
		hidden_message.show()
		gear_image.hide()

	background_dimmer.show()
	background_dimmer.move_to_front()

	dim_instruction_panel()

	attempts_panel.show()
	attempts_panel.modulate = Color.WHITE
	attempts_panel.move_to_front()
	attempts_label.modulate = Color.WHITE

	scratch_popup.show()
	scratch_popup.move_to_front()

	scratch_cover.start_scratching(
		fruit_to_scratch,
		fruit_name == "Grapes"
	)


# ==========================================
# SCRATCH COMPLETED: CHECK RESULT
# ==========================================

func _on_scratch_completed() -> void:
	if selected_fruit == null:
		return

	var fruit_name: String = str(selected_fruit.name)

	if fruit_name == "Grapes":
		game_won = true

		scratch_title.text = "YOU FOUND THE GEAR!"

		# Keep the gear visible at its original size.
		gear_image.show()

		# Start continuous green flashing only after
		# the Grapes scratch completion signal is received.
		play_green_screen_flash()

		notification_label.text = "Correct! You found the hidden gear!"

		show_result_effect(true)
		disable_all_fruits()

	else:
		scratch_title.text = "NOT THIS FRUIT!"

		if not selected_fruits.has(fruit_name):
			selected_fruits.append(fruit_name)
			attempts_left -= 1

		selected_fruit.disabled = true
		selected_fruit.modulate = Color(1.0, 1.0, 1.0, 0.4)

		if attempts_left <= 0:
			notification_label.text = (
				"Game over! You couldn't find the gear."
			)
			disable_all_fruits()
		else:
			notification_label.text = (
				"No gear here! Close this window and try another fruit."
			)

		hidden_message.show()

		update_attempts_label()

		await get_tree().create_timer(1.2).timeout

		if not is_inside_tree():
			return

		if selected_fruit == null or not scratch_popup.visible:
			return

		show_result_effect(false)


# ==========================================
# CLOSE SCRATCH POPUP
# ==========================================

func _on_close_button_pressed() -> void:
	# Stop continuous green flashing immediately.
	if green_flash_tween and green_flash_tween.is_running():
		green_flash_tween.kill()

	green_flash.color.a = 0.0
	green_flash.hide()

	scratch_cover.stop_scratching()

	selected_fruit = null

	scratch_popup.hide()
	background_dimmer.hide()

	# Hide the gear when leaving the scratch popup.
	gear_image.hide()

	reset_result_notification()

	restore_instruction_panel()

	attempts_panel.modulate = Color.WHITE
	attempts_label.modulate = Color.WHITE

	instruction_label.text = (
		"Choose a fruit to scratch and discover what's hidden inside!"
	)


# ==========================================
# ATTEMPTS
# ==========================================

func update_attempts_label() -> void:
	attempts_label.text = "Attempts: " + str(attempts_left)


func disable_all_fruits() -> void:
	for fruit in fruits:
		fruit.disabled = true


# ==========================================
# HOVER: MOVE 5 PIXELS RIGHT
# ==========================================

func _on_fruit_mouse_entered(fruit: TextureButton) -> void:
	if fruit.disabled or selected_fruit != null:
		return

	var original_position: Vector2 = fruit_original_positions[fruit]

	animate_fruit(
		fruit,
		original_position + Vector2(5, 0)
	)


func _on_fruit_mouse_exited(fruit: TextureButton) -> void:
	var original_position: Vector2 = fruit_original_positions[fruit]

	animate_fruit(
		fruit,
		original_position
	)


func animate_fruit(
	fruit: TextureButton,
	target_position: Vector2
) -> void:
	if fruit_tweens.has(fruit):
		var old_tween: Tween = fruit_tweens[fruit]

		if old_tween.is_running():
			old_tween.kill()

	var tween: Tween = create_tween()
	fruit_tweens[fruit] = tween

	tween.tween_property(
		fruit,
		"position",
		target_position,
		0.15
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
