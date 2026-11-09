extends Panel

@export var popup_duration: float = 0.5
@export var typing_speed: float = 0.09

@onready var dialogue_text: Label = $DialogueText

func _ready() -> void:
	hide()

func play_popup() -> void:
	scale = Vector2(0.5, 0.5)
	modulate.a = 0.0
	pivot_offset = size / 2.0
	dialogue_text.visible_characters = 0

	show()

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		popup_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		popup_duration
	)

	await tween.finished
	await start_typing()


func start_typing() -> void:
	for i in range(dialogue_text.text.length()):
		dialogue_text.visible_characters = i + 1
		await get_tree().create_timer(typing_speed).timeout

	dialogue_text.visible_characters = -1
