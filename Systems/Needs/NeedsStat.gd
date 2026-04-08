class_name NeedStat
extends Resource

@export var id: StringName
@export_range(0.0, 100.0) var current_value: float = 100.0
@export_range(0.0, 100.0) var max_value: float = 100.0
@export var decay_per_second: float = 0.0

func decrease(delta_seconds: float) -> void:
	current_value = max(current_value - decay_per_second * delta_seconds, 0.0)

func increase(amount: float) -> void:
	current_value = min(current_value + amount, max_value)

func get_normalized() -> float:
	if max_value <= 0.0:
		return 0.0
	return current_value / max_value
