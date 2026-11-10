
extends Control

@export var typing_speed: float = 0.05
@export var popup_duration: float = 0.4

@onready var dim_overlay: ColorRect = $DimOverlay
@onready var instruction_panel: TextureRect = $InstructionPanel
@onready var instruction_label: Label = $InstructionPanel/InstructionLabel
@onready var got_it_button: Button = $InstructionPanel/GotItButton


func _ready() -> void:
	hide_instruction()
	style_got_it_button()


func show_instruction() -> void:
	dim_overlay.show()
	instruction_panel.show()

	# Prepare popup animation
	instruction_panel.scale = Vector2(0.8, 0.8)
	instruction_panel.modulate.a = 0.0
	instruction_panel.pivot_offset = instruction_panel.size / 2.0

	# Prepare typing effect
	instruction_label.visible_characters = 0

	# Dim screen
	dim_overlay.modulate.a = 0.0

	var dim_tween := create_tween()
	dim_tween.tween_property(
		dim_overlay,
		"modulate:a",
		0.65,
		0.3
	)

	# Pop out instruction panel
	var popup_tween := create_tween()
	popup_tween.set_parallel(true)

	popup_tween.tween_property(
		instruction_panel,
		"scale",
		Vector2.ONE,
		popup_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	popup_tween.tween_property(
		instruction_panel,
		"modulate:a",
		1.0,
		popup_duration
	)

	await popup_tween.finished

	# Type the instruction
	await start_typing()


func start_typing() -> void:
	for i in range(instruction_label.text.length()):
		instruction_label.visible_characters = i + 1
		await get_tree().create_timer(typing_speed).timeout

	instruction_label.visible_characters = -1


func hide_instruction() -> void:
	dim_overlay.hide()
	instruction_panel.hide()


func _on_got_it_pressed() -> void:
	hide_instruction()


func style_got_it_button() -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#548C57")
	normal.set_corner_radius_all(10)
	normal.set_border_width_all(2)
	normal.border_color = Color("#3F7043")

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color("#70AD72")
	hover.set_corner_radius_all(10)
	hover.set_border_width_all(2)
	hover.border_color = Color("#548C57")

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color("#386B3D")
	pressed.set_corner_radius_all(10)
	pressed.set_border_width_all(2)
	pressed.border_color = Color("#2D5832")

	got_it_button.add_theme_stylebox_override("normal", normal)
	got_it_button.add_theme_stylebox_override("hover", hover)
	got_it_button.add_theme_stylebox_override("pressed", pressed)

	got_it_button.add_theme_color_override(
		"font_color", Color.WHITE
	)
	got_it_button.add_theme_color_override(
		"font_hover_color", Color.WHITE
	)
	got_it_button.add_theme_color_override(
		"font_pressed_color", Color("#E0E0E0")
	)

	got_it_button.pressed.connect(_on_got_it_pressed)
