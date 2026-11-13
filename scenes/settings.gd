
extends Control

# MAIN SETTINGS ELEMENTS
@onready var frame: Control = $Frame
@onready var separator_line: Control = $separatorline

# NAVIGATION TABS
@onready var audio_tab: Control = $audio
@onready var controls_tab: Control = $controls
@onready var about_tab: Control = $about

# CONTENT PANELS
@onready var audio_content: Control = $AudioContent
@onready var controls_content: Control = $ControlsContent
@onready var about_content: Control = $AboutContent


# HOVER SETTINGS
const HOVER_SCALE: float = 1.045
const HOVER_DURATION: float = 0.16
const HOVER_BRIGHTNESS: float = 0.12

var base_scales: Dictionary = {}
var base_modulates: Dictionary = {}
var hover_tweens: Dictionary = {}


func _ready() -> void:
	await get_tree().process_frame

	# Hide all content panels initially.
	audio_content.hide()
	controls_content.hide()
	about_content.hide()

	# Prepare navigation tabs.
	_setup_hover(audio_tab)
	_setup_hover(controls_tab)
	_setup_hover(about_tab)

	# Hide navigation elements before their animation.
	# Their editor positions and sizes are preserved.
	_prepare_hidden(separator_line)
	_prepare_hidden(audio_tab)
	_prepare_hidden(controls_tab)
	_prepare_hidden(about_tab)

	# Animate the main decorative frame first.
	await _play_frame_animation()

	# Reveal separator and navigation tabs simultaneously.
	_play_reveal_animation(separator_line, 0.0, 0.65)

	_play_reveal_animation(audio_tab, 0.0, 0.65)
	_play_reveal_animation(controls_tab, 0.0, 0.65)
	_play_reveal_animation(about_tab, 0.0, 0.65)


# ==========================================
# FRAME POPUP ANIMATION
# ==========================================

func _play_frame_animation() -> void:

	var original_position: Vector2 = frame.position
	var original_scale: Vector2 = frame.scale
	var original_alpha: float = frame.modulate.a

	frame.pivot_offset = frame.size / 2.0

	# Start smaller and slightly lower.
	frame.position = original_position + Vector2(0, 25)
	frame.scale = original_scale * 0.72

	var color: Color = frame.modulate
	color.a = 0.0
	frame.modulate = color

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		frame,
		"modulate:a",
		original_alpha,
		1.0
	)

	tween.parallel().tween_property(
		frame,
		"scale",
		original_scale,
		1.1
	)

	tween.parallel().tween_property(
		frame,
		"position",
		original_position,
		1.0
	)

	await tween.finished


# ==========================================
# PREPARE NAVIGATION ELEMENTS
# ==========================================

func _prepare_hidden(node: Control) -> void:

	# Save the original appearance before hiding it.
	base_modulates[node] = node.modulate

	node.visible = true

	var color: Color = node.modulate
	color.a = 0.0
	node.modulate = color

	node.position += Vector2(0, 10)


# ==========================================
# NAVIGATION REVEAL ANIMATION
# ==========================================

func _play_reveal_animation(
	node: Control,
	delay: float,
	duration: float
) -> void:

	var original_position: Vector2 = node.position - Vector2(0, 10)
	var original_scale: Vector2 = node.scale
	var original_alpha: float = base_modulates.get(node, node.modulate).a

	node.pivot_offset = node.size / 2.0

	var tween := create_tween()

	tween.tween_interval(delay)

	tween.tween_property(
		node,
		"modulate:a",
		original_alpha,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		node,
		"position",
		original_position,
		duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		node,
		"scale",
		original_scale,
		duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# ==========================================
# HOVER EFFECT SETUP
# ==========================================

func _setup_hover(tab: Control) -> void:

	tab.pivot_offset = tab.size / 2.0

	tab.mouse_filter = Control.MOUSE_FILTER_STOP
	tab.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	base_scales[tab] = tab.scale
	base_modulates[tab] = tab.modulate

	# Allow the mouse to interact with the tab itself,
	# not get intercepted by its text label.
	for child in tab.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

	tab.mouse_entered.connect(
		_on_tab_mouse_entered.bind(tab)
	)

	tab.mouse_exited.connect(
		_on_tab_mouse_exited.bind(tab)
	)

	# Connect tab clicks.
	tab.gui_input.connect(
		_on_tab_gui_input.bind(tab)
	)


# ==========================================
# TAB CLICK
# ==========================================

func _on_tab_gui_input(event: InputEvent, tab: Control) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			_show_content(tab)

			get_viewport().set_input_as_handled()


# ==========================================
# SHOW SELECTED CONTENT
# ==========================================

func _show_content(tab: Control) -> void:

	# Hide every content panel first.
	audio_content.hide()
	controls_content.hide()
	about_content.hide()

	# Show only the content matching the selected tab.
	if tab == audio_tab:
		audio_content.show()

	elif tab == controls_tab:
		controls_content.show()

	elif tab == about_tab:
		about_content.show()


# ==========================================
# HOVER ENTER
# ==========================================

func _on_tab_mouse_entered(tab: Control) -> void:

	_stop_hover_tween(tab)

	var original_scale: Vector2 = base_scales[tab]
	var original_color: Color = base_modulates[tab]

	var tween := create_tween()

	hover_tweens[tab] = tween

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		tab,
		"scale",
		original_scale * HOVER_SCALE,
		HOVER_DURATION
	)

	tween.parallel().tween_property(
		tab,
		"modulate",
		original_color.lightened(HOVER_BRIGHTNESS),
		HOVER_DURATION
	)


# ==========================================
# HOVER EXIT
# ==========================================

func _on_tab_mouse_exited(tab: Control) -> void:

	_stop_hover_tween(tab)

	var original_scale: Vector2 = base_scales[tab]
	var original_color: Color = base_modulates[tab]

	var tween := create_tween()

	hover_tweens[tab] = tween

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		tab,
		"scale",
		original_scale,
		HOVER_DURATION
	)

	tween.parallel().tween_property(
		tab,
		"modulate",
		original_color,
		HOVER_DURATION
	)


# ==========================================
# STOP PREVIOUS HOVER TWEEN
# ==========================================

func _stop_hover_tween(tab: Control) -> void:

	if hover_tweens.has(tab):
		var previous_tween: Tween = hover_tweens[tab]

		if previous_tween != null and previous_tween.is_running():
			previous_tween.kill()

		hover_tweens.erase(tab)
