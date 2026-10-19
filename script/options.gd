extends Button

@export var hover_distance := -8.0
@export var animation_time := 0.15

var original_position: Vector2

func _ready():
	original_position = position
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self,
		"position",
		original_position + Vector2(hover_distance, 0),
		animation_time
	)

func _on_mouse_exited():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self,
		"position",
		original_position,
		animation_time
	)
