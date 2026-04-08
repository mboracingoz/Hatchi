extends Node

signal hunger_changed(value: float)

var hunger: NeedStat

func _ready() -> void:
	hunger = NeedStat.new()
	hunger.id = &"hunger"
	hunger.max_value = 100.0
	hunger.current_value = 70.0
	hunger.decay_per_second = 1.0

	_emit_hunger_changed()
	

func _process(delta: float) -> void:
	if hunger == null:
		return

	var previous_value: float = hunger.current_value
	hunger.decrease(delta)

	if !is_equal_approx(previous_value, hunger.current_value):
		_emit_hunger_changed()
		print("Hunger current value: ", hunger.current_value)


func feed(amount: float) -> void:
	if hunger == null:
		return

	hunger.increase(amount)
	_emit_hunger_changed()

func _emit_hunger_changed() -> void:
	hunger_changed.emit(hunger.current_value)
