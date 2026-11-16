
extends Area2D

@export var object_texture: Texture2D

@onready var object_sprite: Sprite2D = $ObjectSprite
@onready var interaction_range: Area2D = $InteractionRange
@onready var glow_sprite: Sprite2D = $GlowSprite

var player_in_range: bool = false


func _ready() -> void:

	# =====================================
	# ASSIGN OBJECT TEXTURE
	# =====================================

	if object_texture:
		object_sprite.texture = object_texture

	# Copy ObjectSprite texture to GlowSprite
	glow_sprite.texture = object_sprite.texture

	print("OBJECT TEXTURE: ", object_sprite.texture)
	print("GLOW TEXTURE: ", glow_sprite.texture)

	# Enable mouse detection
	input_pickable = true

	# =====================================
	# CONFIGURE GLOW SPRITE
	# =====================================

	glow_sprite.position = object_sprite.position
	glow_sprite.rotation = object_sprite.rotation
	glow_sprite.centered = object_sprite.centered
	glow_sprite.offset = object_sprite.offset

	glow_sprite.scale = object_sprite.scale * 1.15
	glow_sprite.z_index = object_sprite.z_index - 1

	glow_sprite.modulate = Color(1.0, 0.65, 0.15, 0.0)
	glow_sprite.visible = false

	# =====================================
	# CONNECT PROXIMITY DETECTION SIGNALS
	# =====================================

	interaction_range.body_entered.connect(_on_body_entered)
	interaction_range.body_exited.connect(_on_body_exited)

	# =====================================
	# CHECK IF CHAPTER 1 DIALOGUE IS COMPLETED
	# =====================================

	var dialogue_completed = get_tree().root.get_meta(
		"chapter1_dialogue_completed", false
	)

	print("CHAPTER 1 COMPLETED: ", dialogue_completed)

	if dialogue_completed:
		start_glow()


# =====================================
# OBJECT GLOW - TEMPORARY VISUAL TEST
# =====================================


func start_glow() -> void:

	print("STARTING OBJECT GLOW!")

	# Match ObjectSprite's local position
	glow_sprite.position = object_sprite.position
	glow_sprite.rotation = object_sprite.rotation
	glow_sprite.offset = object_sprite.offset
	glow_sprite.centered = object_sprite.centered

	# Assign texture again
	glow_sprite.texture = object_sprite.texture

	# Force the sprite to render in front
	glow_sprite.visible = true
	glow_sprite.modulate = Color.RED
	glow_sprite.scale = object_sprite.scale * 1.5
	glow_sprite.z_index = object_sprite.z_index + 1

	print("GLOW VISIBLE: ", glow_sprite.visible)
	print("GLOW POSITION: ", glow_sprite.position)
	print("GLOW GLOBAL POSITION: ", glow_sprite.global_position)
	print("GLOW TEXTURE: ", glow_sprite.texture)
	print("GLOW TOP LEVEL: ", glow_sprite.is_set_as_top_level())



# =====================================
# PLAYER ENTERS INTERACTION RANGE
# =====================================

func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):
		player_in_range = true
		print("PLAYER ENTERED INTERACTION RANGE")


# =====================================
# PLAYER EXITS INTERACTION RANGE
# =====================================

func _on_body_exited(body: Node2D) -> void:

	if body.is_in_group("player"):
		player_in_range = false
		print("PLAYER LEFT INTERACTION RANGE")


# =====================================
# MOUSE CLICK INTERACTION
# =====================================

func _input_event(
	_viewport: Viewport,
	event: InputEvent,
	_shape_idx: int
) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			print("MOUSE CLICK DETECTED")

			if player_in_range:

				print("OBJECT INTERACTION SUCCESSFUL!")

				# Change scene to flashback
				#get_tree().change_scene_to_file(
					#"res://scenes/gameplay_intro/chap2_intro.tscn"
				#)

			else:

				print("PLAYER IS TOO FAR AWAY")
