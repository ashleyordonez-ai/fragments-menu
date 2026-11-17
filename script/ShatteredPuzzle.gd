
extends Control

@export var portrait_path: NodePath = "../PortraitPicture"

const COLUMNS := 4
const ROWS := 4

# =====================================
# NEXT SCENE
# =====================================

const NEXT_SCENE := "res://scenes/Chapter 3/Chapter 3_Present-Scene.tscn"

# How visibly separated the pieces should look
const OFFSET_AMOUNT := 18.0
const ROTATION_AMOUNT := 12.0

# Snapping distance
const SNAP_DISTANCE := 45.0

var rng := RandomNumberGenerator.new()
var portrait: TextureRect

# Drag-and-drop variables
var selected_piece: Node2D = null
var drag_offset: Vector2 = Vector2.ZERO
var can_drag: bool = false

# Snapping variables
var piece_correct_positions: Dictionary = {}
var locked_pieces: Array[Node2D] = []

# Prevent multiple completion transitions
var puzzle_completed: bool = false

var completion_glow_tween: Tween

@export var dialogue_delay: float = 2.5
@export var dialogue_panel_path: NodePath = "../DialoguePanel"
@onready var dialogue_panel = get_node_or_null(dialogue_panel_path)

@export var instruction_ui_path: NodePath = "../InstructionUI"
@onready var instruction_ui = get_node_or_null(instruction_ui_path)

# SANITY UI
@onready var sanity_ui: Control = $"../SanityUI"


# =====================================
# INITIALIZE
# =====================================

func _ready() -> void:

	rng.randomize()
	create_shattered_picture()

	# Keep sanity bar hidden until player starts building
	sanity_ui.hide()

	if dialogue_panel == null:
		push_error("Cannot find DialoguePanel!")
		return

	if instruction_ui == null:
		push_error("Cannot find InstructionUI!")
		return

	# Connect GotItButton
	var got_it_button := instruction_ui.get_node_or_null(
		"InstructionPanel/GotItButton"
	) as Button

	if got_it_button == null:
		push_error("Cannot find GotItButton!")
		return

	if not got_it_button.pressed.is_connected(_on_instruction_dismissed):
		got_it_button.pressed.connect(_on_instruction_dismissed)

	dialogue_panel.hide()

	await get_tree().create_timer(dialogue_delay).timeout

	await dialogue_panel.play_popup()

	# Make dialogue panel disappear
	var fade_tween := create_tween()

	fade_tween.tween_property(
		dialogue_panel,
		"modulate:a",
		0.0,
		0.3
	)

	await fade_tween.finished

	dialogue_panel.hide()

	# Scatter picture pieces
	await scatter_pieces()

	# Give player time to see scattered pieces
	await get_tree().create_timer(0.4).timeout

	# Show instruction popup
	instruction_ui.show_instruction()


# =====================================
# CREATE SHATTERED PICTURE
# =====================================

func create_shattered_picture() -> void:

	portrait = get_node_or_null(portrait_path) as TextureRect

	if portrait == null or portrait.texture == null:
		push_error("PortraitPicture or its texture is missing!")
		return

	# Remove previously generated pieces
	for child in get_children():
		remove_child(child)
		child.queue_free()

	# Get only the cropped portrait region
	var texture: Texture2D = get_portrait_region_texture(portrait.texture)

	if texture == null:
		push_error("Could not extract the portrait texture region!")
		return

	var texture_size := Vector2(
		texture.get_width(),
		texture.get_height()
	)

	var piece_width := portrait.size.x / COLUMNS
	var piece_height := portrait.size.y / ROWS

	# Randomize shared jigsaw edges
	var horizontal_signs := []
	var vertical_signs := []

	for y in range(ROWS + 1):
		var row_signs := []

		for x in range(COLUMNS):
			row_signs.append(
				1.0 if rng.randi_range(0, 1) == 0 else -1.0
			)

		horizontal_signs.append(row_signs)

	for y in range(ROWS):
		var row_signs := []

		for x in range(COLUMNS + 1):
			row_signs.append(
				1.0 if rng.randi_range(0, 1) == 0 else -1.0
			)

		vertical_signs.append(row_signs)

	# Generate all 16 pieces
	for y in range(ROWS):
		for x in range(COLUMNS):
			create_piece(
				texture,
				texture_size,
				piece_width,
				piece_height,
				x,
				y,
				horizontal_signs,
				vertical_signs
			)

	# Hide original portrait
	portrait.hide()


# =====================================
# GET PORTRAIT REGION TEXTURE
# =====================================

func get_portrait_region_texture(source_texture: Texture2D) -> Texture2D:

	var image: Image

	# If using AtlasTexture, extract ONLY its selected region
	if source_texture is AtlasTexture:

		var atlas_texture := source_texture as AtlasTexture

		if atlas_texture.atlas == null:
			push_error("AtlasTexture has no atlas assigned!")
			return null

		var atlas_image: Image = atlas_texture.atlas.get_image()

		if atlas_image == null or atlas_image.is_empty():
			push_error("Could not read the atlas image!")
			return null

		image = atlas_image.get_region(atlas_texture.region)

	else:

		# Support ordinary textures too
		image = source_texture.get_image()

	if image == null or image.is_empty():
		push_error("The portrait image is empty!")
		return null

	return ImageTexture.create_from_image(image)


# =====================================
# CREATE PUZZLE PIECE
# =====================================

func create_piece(
	texture: Texture2D,
	texture_size: Vector2,
	pw: float,
	ph: float,
	x: int,
	y: int,
	h_signs: Array,
	v_signs: Array
) -> void:

	var left := x * pw
	var right := (x + 1) * pw
	var top := y * ph
	var bottom := (y + 1) * ph

	var center := Vector2(
		(left + right) / 2.0,
		(top + bottom) / 2.0
	)

	var points: Array[Vector2] = []

	# Top edge
	points.append_array(edge_points(
		Vector2(left, top),
		Vector2(right, top),
		Vector2.UP,
		h_signs[y][x],
		y != 0
	))

	# Right edge
	points.append_array(edge_points(
		Vector2(right, top),
		Vector2(right, bottom),
		Vector2.RIGHT,
		v_signs[y][x + 1],
		x != COLUMNS - 1
	))

	# Bottom edge
	points.append_array(edge_points(
		Vector2(right, bottom),
		Vector2(left, bottom),
		Vector2.DOWN,
		-h_signs[y + 1][x],
		y != ROWS - 1
	))

	# Left edge
	points.append_array(edge_points(
		Vector2(left, bottom),
		Vector2(left, top),
		Vector2.LEFT,
		-v_signs[y][x],
		x != 0
	))

	var local_points := PackedVector2Array()
	var uvs := PackedVector2Array()

	for point in points:

		local_points.append(point - center)

		uvs.append(Vector2(
			point.x / portrait.size.x * texture_size.x,
			point.y / portrait.size.y * texture_size.y
		))

	var piece := Node2D.new()
	piece.name = "Piece_%d_%d" % [x, y]

	# Save correct position
	var correct_position := portrait.position + center

	# Slightly shift and rotate each piece
	piece.position = correct_position + Vector2(
		rng.randf_range(-OFFSET_AMOUNT, OFFSET_AMOUNT),
		rng.randf_range(-OFFSET_AMOUNT, OFFSET_AMOUNT)
	)

	piece_correct_positions[piece] = correct_position

	piece.rotation_degrees = rng.randf_range(
		-ROTATION_AMOUNT,
		ROTATION_AMOUNT
	)

	add_child(piece)

	var polygon := Polygon2D.new()
	polygon.name = "Polygon2D"
	polygon.polygon = local_points
	polygon.uv = uvs
	polygon.texture = texture

	piece.add_child(polygon)


# =====================================
# JIGSAW EDGE POINTS
# =====================================

func edge_points(
	start: Vector2,
	finish: Vector2,
	normal: Vector2,
	sign: float,
	has_tab: bool
) -> Array[Vector2]:

	var result: Array[Vector2] = []
	var samples := 16

	var edge_length := start.distance_to(finish)
	var tab_size := minf(edge_length * 0.20, 17.0)

	for i in range(samples + 1):

		var t := float(i) / samples
		var point := start.lerp(finish, t)

		if has_tab:

			var profile := pow(sin(PI * t), 2.0)
			var displacement := sign * tab_size * profile

			point += normal * displacement

		result.append(point)

	return result


# =====================================
# SCATTER PUZZLE PIECES
# =====================================

func scatter_pieces() -> void:

	var pieces := get_children()

	var portrait_rect := Rect2(portrait.position, portrait.size)

	var piece_width: float = portrait.size.x / COLUMNS
	var piece_height: float = portrait.size.y / ROWS

	var half_height: float = piece_height / 2.0

	var screen_height: float = get_viewport_rect().size.y

	var scatter_tween := create_tween()
	scatter_tween.set_parallel(true)

	for i in range(pieces.size()):

		var piece = pieces[i]

		if not piece is Node2D:
			continue

		var target_position: Vector2

		if i < 14:

			var side_index: int = int(i / 2)

			var target_y: float = screen_height * (side_index + 1) / 8.0

			if i % 2 == 0:

				target_position = Vector2(
					portrait_rect.position.x - piece_width * 1.25,
					target_y
				)

			else:

				target_position = Vector2(
					portrait_rect.end.x + piece_width * 1.25,
					target_y
				)

		else:

			var bottom_index: int = i - 14

			target_position = Vector2(
				portrait_rect.position.x
					+ portrait_rect.size.x * (bottom_index + 1) / 3.0,
				min(
					portrait_rect.end.y + piece_height * 1.65,
					screen_height - half_height - 8
				)
			)

		scatter_tween.tween_property(
			piece,
			"position",
			target_position,
			0.35
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		scatter_tween.tween_property(
			piece,
			"rotation_degrees",
			piece.rotation_degrees + rng.randf_range(-45, 45),
			0.35
		)

	await scatter_tween.finished


# =====================================
# INSTRUCTION POPUP
# =====================================

func _on_instruction_dismissed() -> void:

	can_drag = true


# =====================================
# MOUSE INPUT
# =====================================

func _input(event: InputEvent) -> void:

	if not can_drag or puzzle_completed:
		return

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:
				start_drag()
			else:
				stop_drag()

	elif event is InputEventMouseMotion:

		if selected_piece != null:

			selected_piece.global_position = (
				get_global_mouse_position() + drag_offset
			)

			get_viewport().set_input_as_handled()


# =====================================
# START DRAGGING
# =====================================

func start_drag() -> void:

	var mouse_position: Vector2 = get_global_mouse_position()

	for i in range(get_child_count() - 1, -1, -1):

		var piece := get_child(i) as Node2D

		if piece == null:
			continue

		if piece in locked_pieces:
			continue

		var polygon := piece.get_node_or_null("Polygon2D") as Polygon2D

		if polygon == null:
			continue

		var local_mouse_position := piece.to_local(mouse_position)

		if Geometry2D.is_point_in_polygon(
			local_mouse_position,
			polygon.polygon
		):

			selected_piece = piece
			drag_offset = piece.global_position - mouse_position

			# Show sanity bar
			sanity_ui.show()

			selected_piece.z_index = 100

			get_viewport().set_input_as_handled()
			return


# =====================================
# STOP DRAGGING
# =====================================

func stop_drag() -> void:

	if selected_piece == null:
		return

	var correct_position: Vector2 = piece_correct_positions[selected_piece]

	if selected_piece.position.distance_to(correct_position) <= SNAP_DISTANCE:

		snap_piece_into_place(selected_piece)

	else:

		# Deduct 4 sanity points
		SanityManager.decrease_sanity(4)

		selected_piece.z_index = 0

	selected_piece = null

	get_viewport().set_input_as_handled()


# =====================================
# SNAP PIECE INTO PLACE
# =====================================

func snap_piece_into_place(piece: Node2D) -> void:

	var correct_position: Vector2 = piece_correct_positions[piece]

	var snap_tween := create_tween()

	snap_tween.tween_property(
		piece,
		"position",
		correct_position,
		0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await snap_tween.finished

	piece.rotation_degrees = 0
	piece.z_index = 0

	locked_pieces.append(piece)

	print("PUZZLE PIECES COMPLETED: ", locked_pieces.size())

	# CHECK IF ALL 16 PIECES ARE COMPLETED
	if locked_pieces.size() == COLUMNS * ROWS and not puzzle_completed:

		puzzle_completed = true

		print("PUZZLE SOLVED!")

		play_golden_transition()


# =====================================
# GOLDEN LIGHT TRANSITION
# =====================================

func play_golden_transition() -> void:

	print("STARTING GOLDEN TRANSITION...")

	var golden := get_parent().get_node_or_null(
		"GoldenTransition"
	) as ColorRect

	if golden == null:
		push_error("GoldenTransition node not found!")
		return

	var shader_material := golden.material as ShaderMaterial

	if shader_material == null:
		push_error("GoldenTransition has no ShaderMaterial!")
		return

	# CHECK PORTRAIT
	if portrait == null:
		push_error("Portrait node is missing!")
		return

	# GET PORTRAIT SCREEN POSITION
	var viewport_size := get_viewport_rect().size

	var portrait_transform := portrait.get_global_transform_with_canvas()

	var top_left := portrait_transform * Vector2.ZERO
	var top_right := portrait_transform * Vector2(portrait.size.x, 0)
	var bottom_left := portrait_transform * Vector2(0, portrait.size.y)
	var bottom_right := portrait_transform * portrait.size

	# CONVERT TO NORMALIZED SCREEN COORDINATES
	shader_material.set_shader_parameter(
		"corner_top_left",
		top_left / viewport_size
	)

	shader_material.set_shader_parameter(
		"corner_top_right",
		top_right / viewport_size
	)

	shader_material.set_shader_parameter(
		"corner_bottom_left",
		bottom_left / viewport_size
	)

	shader_material.set_shader_parameter(
		"corner_bottom_right",
		bottom_right / viewport_size
	)

	shader_material.set_shader_parameter(
		"screen_aspect",
		viewport_size.x / viewport_size.y
	)

	# START GOLDEN LIGHT ANIMATION
	shader_material.set_shader_parameter("progress", 0.0)

	golden.visible = true

	var tween := create_tween()

	tween.tween_method(
		func(value: float):
			shader_material.set_shader_parameter("progress", value),
		0.0,
		1.0,
		5.0
	)

	# WAIT FOR GOLDEN TRANSITION TO FINISH
	await tween.finished

	print("GOLDEN TRANSITION COMPLETED!")

	# SMALL DELAY BEFORE SCENE CHANGE
	await get_tree().create_timer(0.5).timeout

	# CHECK NEXT SCENE
	if not ResourceLoader.exists(NEXT_SCENE):

		push_error("NEXT SCENE NOT FOUND: " + NEXT_SCENE)
		return

	# LOAD CHAPTER 3 PRESENT SCENE
	print("LOADING CHAPTER 3 PRESENT SCENE...")

	var error := get_tree().change_scene_to_file(NEXT_SCENE)

	if error != OK:

		push_error(
			"FAILED TO LOAD CHAPTER 3 PRESENT SCENE: " + str(error)
		)

	else:

		print("CHAPTER 3 PRESENT SCENE LOADED SUCCESSFULLY!")
