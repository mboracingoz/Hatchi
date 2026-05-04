extends Node

signal bond_changed(current_bond: float, snapshot: Dictionary)
signal milestone_reached(milestone_id: StringName, snapshot: Dictionary)

const MAX_BOND := 1000.0

const CARE_BOND_REWARDS := {
	&"feed": 3.0,
	&"cuddle": 4.0,
	&"clean": 3.0,
	&"sleep": 2.0,
}

const CHOICE_BOND_REWARD_DEFAULT := 8.0
const MILESTONE_VALUES := {
	&"memory_event": 100.0,
	&"decor_unlock": 300.0,
	&"name_call": 500.0,
	&"deep_bond": 750.0,
	&"graduation_max": 1000.0,
}

var current_bond: float = 0.0
var highest_bond: float = 0.0
var unlocked_milestones: Dictionary = {}
var legacy_bond_total: float = 0.0
var _last_snapshot: Dictionary = {}

@onready var micro_event_controller = get_tree().get_root().find_child("MicroEventController", true, false)
@onready var need_system = get_tree().get_first_node_in_group("need_system")


func _ready() -> void:
	for milestone_id in MILESTONE_VALUES.keys():
		unlocked_milestones[milestone_id] = false

	if micro_event_controller != null and micro_event_controller.has_signal("choice_result_applied"):
		if not micro_event_controller.choice_result_applied.is_connected(_on_choice_result_applied):
			micro_event_controller.choice_result_applied.connect(_on_choice_result_applied)

	if need_system != null and need_system.has_signal("sleep_mode_changed"):
		if not need_system.sleep_mode_changed.is_connected(_on_sleep_mode_changed):
			need_system.sleep_mode_changed.connect(_on_sleep_mode_changed)

	_last_snapshot = get_bond_snapshot()


func record_care_action(action_id: StringName) -> void:
	var reward := float(CARE_BOND_REWARDS.get(action_id, 0.0))
	if reward <= 0.0:
		return

	_add_bond(reward, StringName("care_%s" % action_id))


func record_mini_game_result(minigame_id: StringName, success_level: StringName = &"standard") -> void:
	var reward := 8.0
	if success_level == &"great":
		reward = 12.0
	elif success_level == &"perfect":
		reward = 15.0

	_add_bond(reward, StringName("minigame_%s" % minigame_id))


func apply_neglect_penalty(amount: float) -> void:
	if amount <= 0.0:
		return

	current_bond = max(0.0, current_bond - amount)
	_emit_bond_changed()


func graduate_current_pet() -> void:
	legacy_bond_total += highest_bond


func get_bond_snapshot() -> Dictionary:
	return {
		"current_bond": current_bond,
		"highest_bond": highest_bond,
		"legacy_bond_total": legacy_bond_total,
		"unlocked_milestones": _serialize_milestones(),
		"next_milestone": _get_next_milestone_snapshot(),
	}


func _on_choice_result_applied(event_id: StringName, option_id: StringName, result_data: Dictionary) -> void:
	var reward := float(result_data.get("bond_reward", CHOICE_BOND_REWARD_DEFAULT))
	_add_bond(reward, StringName("choice_%s_%s" % [event_id, option_id]))


func _on_sleep_mode_changed(is_sleeping: bool) -> void:
	if not is_sleeping:
		return

	record_care_action(&"sleep")


func _add_bond(amount: float, _source: StringName) -> void:
	if amount <= 0.0:
		return

	current_bond = min(MAX_BOND, current_bond + amount)
	highest_bond = max(highest_bond, current_bond)
	_check_milestones()
	_emit_bond_changed()


func _check_milestones() -> void:
	for milestone_id in MILESTONE_VALUES.keys():
		if bool(unlocked_milestones.get(milestone_id, false)):
			continue
		if current_bond < float(MILESTONE_VALUES[milestone_id]):
			continue

		unlocked_milestones[milestone_id] = true
		milestone_reached.emit(milestone_id, get_bond_snapshot())


func _emit_bond_changed() -> void:
	_last_snapshot = get_bond_snapshot()
	bond_changed.emit(current_bond, _last_snapshot)


func _serialize_milestones() -> Dictionary:
	var snapshot := {}
	for milestone_id in unlocked_milestones.keys():
		snapshot[String(milestone_id)] = unlocked_milestones[milestone_id]
	return snapshot


func _get_next_milestone_snapshot() -> Dictionary:
	var next_id: StringName = &""
	var next_value := INF

	for milestone_id in MILESTONE_VALUES.keys():
		if bool(unlocked_milestones.get(milestone_id, false)):
			continue
		var candidate := float(MILESTONE_VALUES[milestone_id])
		if candidate >= next_value:
			continue
		next_value = candidate
		next_id = milestone_id

	if next_id == &"":
		return {
			"id": "",
			"target_bond": MAX_BOND,
			"remaining": 0.0,
		}

	return {
		"id": String(next_id),
		"target_bond": next_value,
		"remaining": max(0.0, next_value - current_bond),
	}
