extends Node

signal hunger_changed(value: float)
signal need_changed(need_id: StringName, value: float, normalized: float)
signal sleep_mode_changed(is_sleeping: bool)

var needs = {}
var is_sleeping: bool = false
@onready var egg_system = get_tree().get_first_node_in_group("egg_system")

const SLEEP_INTERRUPT_HUNGER_THRESHOLD := 15.0
const AUTO_SLEEP_THRESHOLD := 0.0
const SLEEP_RECOVERY_PER_SECOND := 1.2
const SLEEPING_HUNGER_DECAY_MULTIPLIER := 0.35
const SLEEPING_HAPPINESS_DECAY_MULTIPLIER := 0.15
const SLEEPING_HYGIENE_DECAY_MULTIPLIER := 0.1

func _ready() -> void:
	var hunger = NeedStat.new()
	hunger.id = &"hunger"
	hunger.max_value = 100.0
	hunger.current_value = 10.0
	hunger.decay_per_second = 1.0

	needs["hunger"] = hunger
	
	var happiness = NeedStat.new()
	happiness.id = &"happiness"
	happiness.max_value = 100.0
	happiness.current_value = 80.0
	happiness.decay_per_second = 0.5
	
	needs["happiness"] = happiness
	
	var hygiene = NeedStat.new()
	hygiene.id = &"hygiene"
	hygiene.max_value = 100.0
	hygiene.current_value = 85.0
	hygiene.decay_per_second = 0.3
	
	needs["hygiene"] = hygiene
	
	var sleep = NeedStat.new()
	sleep.id = &"sleep"
	sleep.max_value = 100.0
	sleep.current_value = 75.0
	sleep.decay_per_second = 0.2
	
	needs["sleep"] = sleep
	
	_emit_hunger_changed()

func _process(delta: float) -> void:
	if _is_gameplay_locked():
		return

	for key in needs.keys():
		var stat: NeedStat = needs[key]
		
		if stat == null:
			continue
		
		var previous_value := stat.current_value
		_update_need(stat, delta)
		if !is_equal_approx(previous_value, stat.current_value):
			_emit_need_updated(key)
	
	_update_sleep_mode_from_needs()
	_emit_hunger_changed()

func feed(amount: float) -> void:
	var hunger: NeedStat = needs.get("hunger")

	if hunger == null:
		return

	hunger.increase(amount)
	_emit_need_updated("hunger")
	_emit_hunger_changed()

func add_happiness(amount: float) -> void:
	_increase_need("happiness", amount)

func add_sleep(amount: float) -> void:
	_increase_need("sleep", amount)

func add_hygiene(amount: float) -> void:
	_increase_need("hygiene", amount)

func set_need_value(need_id: String, value: float) -> bool:
	var stat: NeedStat = needs.get(need_id)
	if stat == null:
		return false

	stat.current_value = clampf(value, 0.0, stat.max_value)
	_emit_need_updated(need_id)
	_update_sleep_mode_from_needs()
	_emit_hunger_changed()
	return true

func get_needs_snapshot() -> Dictionary:
	var snapshot := {}
	for key in needs.keys():
		var stat: NeedStat = needs[key]
		if stat == null:
			continue

		snapshot[key] = {
			"id": str(stat.id),
			"current_value": stat.current_value,
			"max_value": stat.max_value,
			"normalized": stat.get_normalized(),
			"decay_per_second": stat.decay_per_second
		}

	snapshot["is_sleeping"] = is_sleeping
	return snapshot

func is_sleeping_enabled() -> bool:
	return is_sleeping

func get_sleep_block_reason() -> String:
	var hunger: NeedStat = needs.get("hunger")
	if hunger != null and hunger.current_value <= SLEEP_INTERRUPT_HUNGER_THRESHOLD:
		return "Too hungry to sleep"

	return ""

func can_start_sleep() -> bool:
	return get_sleep_block_reason().is_empty()

func set_sleeping(value: bool) -> void:
	_set_sleeping(value)

func request_sleep() -> bool:
	if is_sleeping:
		return true

	if not can_start_sleep():
		return false

	_set_sleeping(true)
	return true

func wake_up() -> void:
	_set_sleeping(false)

func toggle_sleep() -> bool:
	if is_sleeping:
		wake_up()
		return true

	return request_sleep()

func _update_need(stat: NeedStat, delta: float) -> void:
	if not is_sleeping:
		stat.decrease(delta)
		return

	if stat.id == &"sleep":
		stat.increase(SLEEP_RECOVERY_PER_SECOND * delta)
		return

	var multiplier := 1.0
	match stat.id:
		&"hunger":
			multiplier = SLEEPING_HUNGER_DECAY_MULTIPLIER
		&"happiness":
			multiplier = SLEEPING_HAPPINESS_DECAY_MULTIPLIER
		&"hygiene":
			multiplier = SLEEPING_HYGIENE_DECAY_MULTIPLIER

	stat.decrease(delta * multiplier)

func _update_sleep_mode_from_needs() -> void:
	var hunger: NeedStat = needs.get("hunger")
	var sleep_stat: NeedStat = needs.get("sleep")

	if hunger == null or sleep_stat == null:
		return

	if is_sleeping and hunger.current_value <= SLEEP_INTERRUPT_HUNGER_THRESHOLD:
		_set_sleeping(false)
		return

	if not is_sleeping and sleep_stat.current_value <= AUTO_SLEEP_THRESHOLD:
		_set_sleeping(true)

func _set_sleeping(value: bool) -> void:
	if is_sleeping == value:
		return

	is_sleeping = value
	sleep_mode_changed.emit(is_sleeping)

func _increase_need(need_id: String, amount: float) -> void:
	var stat: NeedStat = needs.get(need_id)
	if stat == null:
		return

	stat.increase(amount)
	_emit_need_updated(need_id)
	_emit_hunger_changed()

func _emit_hunger_changed() -> void:
	var hunger: NeedStat = needs.get("hunger")

	if hunger == null:
		return

	hunger_changed.emit(hunger.current_value)

func _emit_need_updated(need_id: String) -> void:
	var stat: NeedStat = needs.get(need_id)
	if stat == null:
		return

	need_changed.emit(stat.id, stat.current_value, stat.get_normalized())


func _is_gameplay_locked() -> bool:
	if egg_system == null or not egg_system.has_method("is_gameplay_unlocked"):
		return false

	return not bool(egg_system.is_gameplay_unlocked())
