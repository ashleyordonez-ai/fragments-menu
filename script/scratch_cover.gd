
extends ColorRect

signal scratch_completed

const MASK_SIZE: int = 512
const BRUSH_RADIUS: float = 35.0
const REVEAL_THRESHOLD: float = 0.70

var is_scratching: bool = false
var completed: bool = false

var active_fruit: TextureRect = null
var active_material: ShaderMaterial = null
var last_point: Vector2 = Vector2.ZERO

var scratch_image: Image = null
var scratch_texture: ImageTexture = null

var erased_pixels: int = 0
var scratchable_pixels: int = 0
var scratchable_mask: PackedByteArray = PackedByteArray()
var completion_emitted: bool = false
var active_is_grapes: bool = false


func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)


# ==========================================
# START SCRATCHING
# ==========================================

func start_scratching(fruit: TextureRect, is_grapes: bool = false) -> void:
	if fruit == null or not is_instance_valid(fruit):
		return

	if fruit.texture == null:
		push_warning("ScratchCover: The selected fruit has no texture.")
		return

	if active_fruit != null and is_instance_valid(active_fruit):
		active_fruit.material = null

	active_fruit = fruit
	active_is_grapes = is_grapes
	is_scratching = false
	completed = false
	completion_emitted = false
	last_point = Vector2.ZERO

	create_scratch_mask()

	var scratch_shader := Shader.new()
	scratch_shader.code = """
shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D scratch_mask : filter_nearest;

void fragment() {
	vec4 fruit_color = texture(TEXTURE, UV);
	vec4 mask_color = texture(scratch_mask, UV);

	fruit_color.a *= mask_color.a;
	COLOR = fruit_color;
}
"""

	active_material = ShaderMaterial.new()
	active_material.shader = scratch_shader
	active_material.set_shader_parameter(
		"scratch_mask",
		scratch_texture
	)

	active_fruit.material = active_material

	print("Scratch mask assigned to: ", active_fruit.name)
	print("Is Grapes: ", active_is_grapes)


# ==========================================
# CREATE SCRATCH MASK
# ==========================================

func create_scratch_mask() -> void:
	scratch_image = Image.create(
		MASK_SIZE,
		MASK_SIZE,
		false,
		Image.FORMAT_RGBA8
	)

	scratch_image.fill(Color.WHITE)

	erased_pixels = 0
	scratchable_pixels = 0
	completion_emitted = false

	scratchable_mask.resize(MASK_SIZE * MASK_SIZE)
	scratchable_mask.fill(0)

	var source_texture: Texture2D = active_fruit.texture
	var source_image: Image = source_texture.get_image()

	if source_image == null:
		push_warning("ScratchCover: Could not read fruit texture.")

		scratchable_pixels = MASK_SIZE * MASK_SIZE
		scratchable_mask.fill(1)

	else:
		var source_region := Rect2i(
			Vector2i.ZERO,
			source_image.get_size()
		)

		if source_texture is AtlasTexture:
			var atlas_texture := source_texture as AtlasTexture

			if atlas_texture.atlas != null:
				source_image = atlas_texture.atlas.get_image()
				source_region = atlas_texture.region

				if source_region.size.x <= 0 or source_region.size.y <= 0:
					source_region = Rect2i(
						Vector2i.ZERO,
						source_image.get_size()
					)

		for y in range(MASK_SIZE):
			for x in range(MASK_SIZE):
				var source_x: int = clampi(
					source_region.position.x
					+ int(float(x) / MASK_SIZE * source_region.size.x),
					0,
					source_image.get_width() - 1
				)

				var source_y: int = clampi(
					source_region.position.y
					+ int(float(y) / MASK_SIZE * source_region.size.y),
					0,
					source_image.get_height() - 1
				)

				if source_image.get_pixel(source_x, source_y).a > 0.1:
					var pixel_index: int = y * MASK_SIZE + x
					scratchable_mask[pixel_index] = 1
					scratchable_pixels += 1

		if scratchable_pixels <= 0:
			push_warning("ScratchCover: No visible fruit pixels detected.")
			scratchable_pixels = MASK_SIZE * MASK_SIZE
			scratchable_mask.fill(1)

	scratch_texture = ImageTexture.create_from_image(scratch_image)

	print("Scratch mask initialized: completely intact.")
	print("Scratchable fruit pixels: ", scratchable_pixels)


# ==========================================
# MOUSE INPUT
# ==========================================

func _input(event: InputEvent) -> void:
	if active_fruit == null:
		return

	if not is_instance_valid(active_fruit):
		return

	if not active_fruit.is_visible_in_tree():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var displayed_rect: Rect2 = get_displayed_fruit_rect()

				if displayed_rect.has_point(event.global_position):
					is_scratching = true
					last_point = event.global_position

					erase_at(event.global_position)

					get_viewport().set_input_as_handled()
			else:
				is_scratching = false

	elif event is InputEventMouseMotion and is_scratching:
		add_interpolated_points(
			last_point,
			event.global_position
		)

		last_point = event.global_position
		get_viewport().set_input_as_handled()


# ==========================================
# DISPLAYED FRUIT RECTANGLE
# ==========================================

func get_displayed_fruit_rect() -> Rect2:
	if active_fruit == null or active_fruit.texture == null:
		return Rect2()

	var control_rect: Rect2 = active_fruit.get_global_rect()
	var texture_size: Vector2 = active_fruit.texture.get_size()

	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return control_rect

	var scale_factor: float = minf(
		control_rect.size.x / texture_size.x,
		control_rect.size.y / texture_size.y
	)

	var displayed_size: Vector2 = texture_size * scale_factor

	var displayed_position: Vector2 = control_rect.position + (
		control_rect.size - displayed_size
	) / 2.0

	return Rect2(displayed_position, displayed_size)


# ==========================================
# CONTINUOUS SCRATCH STROKES
# ==========================================

func add_interpolated_points(
	from_position: Vector2,
	to_position: Vector2
) -> void:
	var distance_moved: float = from_position.distance_to(to_position)

	var step_distance: float = maxf(1.0, BRUSH_RADIUS * 0.2)

	var steps: int = maxi(
		1,
		int(ceil(distance_moved / step_distance))
	)

	for i in range(1, steps + 1):
		var progress: float = float(i) / float(steps)

		var point: Vector2 = from_position.lerp(
			to_position,
			progress
		)

		erase_at(point)


# ==========================================
# ERASE AT MOUSE POSITION
# ==========================================

func erase_at(global_position: Vector2) -> void:
	if active_fruit == null or scratch_image == null:
		return

	var displayed_rect: Rect2 = get_displayed_fruit_rect()

	if displayed_rect.size.x <= 0.0 or displayed_rect.size.y <= 0.0:
		return

	if not displayed_rect.has_point(global_position):
		return

	var uv := Vector2(
		(global_position.x - displayed_rect.position.x)
			/ displayed_rect.size.x,
		(global_position.y - displayed_rect.position.y)
			/ displayed_rect.size.y
	)

	var center_x: int = clampi(
		int(uv.x * MASK_SIZE),
		0,
		MASK_SIZE - 1
	)

	var center_y: int = clampi(
		int(uv.y * MASK_SIZE),
		0,
		MASK_SIZE - 1
	)

	var radius_x: int = maxi(
		1,
		int(ceil(BRUSH_RADIUS * MASK_SIZE / displayed_rect.size.x))
	)

	var radius_y: int = maxi(
		1,
		int(ceil(BRUSH_RADIUS * MASK_SIZE / displayed_rect.size.y))
	)

	var changed: bool = false

	var start_x: int = maxi(0, center_x - radius_x)
	var end_x: int = mini(MASK_SIZE, center_x + radius_x + 1)

	var start_y: int = maxi(0, center_y - radius_y)
	var end_y: int = mini(MASK_SIZE, center_y + radius_y + 1)

	for y in range(start_y, end_y):
		for x in range(start_x, end_x):
			var dx: float = float(x - center_x) / float(radius_x)
			var dy: float = float(y - center_y) / float(radius_y)

			if dx * dx + dy * dy > 1.0:
				continue

			var current_pixel: Color = scratch_image.get_pixel(x, y)

			if current_pixel.a > 0.0:
				scratch_image.set_pixel(
					x,
					y,
					Color(1.0, 1.0, 1.0, 0.0)
				)

				var pixel_index: int = y * MASK_SIZE + x

				if scratchable_mask[pixel_index] == 1:
					erased_pixels += 1

				changed = true

	if changed:
		scratch_texture.update(scratch_image)
		check_scratch_completion()


# ==========================================
# CHECK SCRATCH COMPLETION
# ==========================================

func check_scratch_completion() -> void:
	if completion_emitted:
		return

	if scratchable_pixels <= 0:
		return

	var erased_ratio: float = (
		float(erased_pixels) / float(scratchable_pixels)
	)

	var required_threshold: float = (
		0.90 if active_is_grapes else REVEAL_THRESHOLD
	)

	if erased_ratio >= required_threshold:
		completion_emitted = true
		completed = true
		
		print("========== SCRATCH DEBUG ==========")
		print("Is Grapes: ", active_is_grapes)
		print("Erased pixels: ", erased_pixels)
		print("Total scratchable pixels: ", scratchable_pixels)
		print("Erased percentage: ", erased_ratio * 100.0)
		print("Required percentage: ", required_threshold * 100.0)

		print(
			"Scratch completed! Erased: ",
			erased_ratio * 100.0,
			"%"
		)

		scratch_completed.emit()


# ==========================================
# STOP SCRATCHING
# ==========================================

func stop_scratching() -> void:
	is_scratching = false

	if active_fruit != null and is_instance_valid(active_fruit):
		active_fruit.material = null

	active_fruit = null
	active_material = null
	scratch_image = null
	scratch_texture = null
	scratchable_mask.clear()

	last_point = Vector2.ZERO
	erased_pixels = 0
	scratchable_pixels = 0
	completed = false
	completion_emitted = false
	active_is_grapes = false
