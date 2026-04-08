extends Node

signal hunger_changed(value: float)

var needs = {}

func _ready() -> void:
	var hunger = NeedStat.new()
	hunger.id = &"hunger"
	hunger.max_value = 100.0
	hunger.current_value = 70.0
	hunger.decay_per_second = 1.0

	needs["hunger"] = hunger

	_emit_hunger_changed()

func _process(delta: float) -> void:
	var hunger: NeedStat = needs.get("hunger")

	if hunger == null:
		return

	var previous_value: float = hunger.current_value
	hunger.decrease(delta)

	if !is_equal_approx(previous_value, hunger.current_value):
		_emit_hunger_changed()

func feed(amount: float) -> void:
	var hunger: NeedStat = needs.get("hunger")

	if hunger == null:
		return

	hunger.increase(amount)
	_emit_hunger_changed()

func _emit_hunger_changed() -> void:
	var hunger: NeedStat = needs.get("hunger")

	if hunger == null:
		return

	hunger_changed.emit(hunger.current_value)
