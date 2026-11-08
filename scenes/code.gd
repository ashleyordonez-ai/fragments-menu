
extends Label

# ==================================================
# BINARY CODE LABEL COLORS — STATIC, NO BLINKING
# ==================================================

@export var normal_color: Color = Color("#211710")
@export var selected_color: Color = Color("#FFF0CF")
@export var amber_outline: Color = Color("#F2A65A")

var code_labels: Array[Label] = []
var highlighted: bool = false


# ==================================================
# INITIALIZE
# ==================================================

func _ready() -> void:
	code_labels.clear()
	collect_labels(self)
	reset_glow()


# ==================================================
# COLLECT ALL BINARY LABELS
# ==================================================

func collect_labels(node: Node) -> void:
	if node is Label:
		var label := node as Label

		if not code_labels.has(label):
			code_labels.append(label)

	for child in node.get_children():
		collect_labels(child)


# ==================================================
# APPLY STATIC LABEL COLORS
# ==================================================

func apply_label_style(
	label: Label,
	font_color: Color,
	outline_color: Color
) -> void:
	label.add_theme_color_override(
		"font_color",
		font_color
	)

	label.add_theme_color_override(
		"font_outline_color",
		outline_color
	)

	label.add_theme_constant_override(
		"outline_size",
		1
	)

	# No text shadow, glow, or animated effect.
	label.add_theme_color_override(
		"font_shadow_color",
		Color(0, 0, 0, 0)
	)

	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)


# ==================================================
# NORMAL STATE — BLACK TEXT
# ==================================================

func reset_glow() -> void:
	highlighted = false

	for label in code_labels:
		if not is_instance_valid(label):
			continue

		apply_label_style(
			label,
			normal_color,
			normal_color
		)


# ==================================================
# VIEW MORE — STATIC BEIGE TEXT
# ==================================================

func start_glow() -> void:
	highlighted = true

	for label in code_labels:
		if not is_instance_valid(label):
			continue

		apply_label_style(
			label,
			selected_color,
			amber_outline
		)


# ==================================================
# CLOSE GUIDE — RETURN TO BLACK
# ==================================================

func stop_glow() -> void:
	reset_glow()
