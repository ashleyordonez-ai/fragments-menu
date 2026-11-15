
extends Node

signal sanity_changed(current_sanity: int)

const MAX_SANITY := 100

var current_sanity: int = MAX_SANITY


func reset_sanity() -> void:
	current_sanity = MAX_SANITY
	sanity_changed.emit(current_sanity)


func decrease_sanity(amount: int) -> void:
	current_sanity = clampi(
		current_sanity - amount,
		0,
		MAX_SANITY
	)

	sanity_changed.emit(current_sanity)


func increase_sanity(amount: int) -> void:
	current_sanity = clampi(
		current_sanity + amount,
		0,
		MAX_SANITY
	)

	sanity_changed.emit(current_sanity)
