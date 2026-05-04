extends Node

signal stage_changed(previous_stage: StringName, current_stage: StringName, snapshot: Dictionary)
signal progression_updated(snapshot: Dictionary)

const STAGE_EGG := &"egg"
const STAGE_BABY := &"baby"
const STAGE_JUVENILE := &"juvenile"
const STAGE_ADULT := &"adult"
const STAGE_FINAL_FORM := &"final_form"

const BABY_TO_JUVENILE_REQUIREMENTS := {
	"feed_count": 10,
	"play_session_count": 5,
	"personality_event_count": 1,
}

const JUVENILE_TO_ADULT_REQUIREMENTS := {
	"bond_threshold": 100.0,
	"mini_game_count": 3,
}

const ADULT_TO_FINAL_FORM_REQUIREMENTS := {
	"personality_event_count": 20,
	"clean_count": 5,
	"mini_game_count": 3,
}

var current_stage: StringName = STAGE_EGG
var previous_stage: StringName = STAGE_EGG
var counters := {
	"feed_count": 0,
	"play_session_count": 0,
	"clean_count": 0,
	"personality_event_count": 0,
	"mini_game_count": 0,
}

@onready var micro_event_controller = get_tree().get_root().find_child("MicroEventController", true, false)
@onready var bond_system = get_tree().get_first_node_in_group("bond_system")
@onready var egg_system = get_tree().get_first_node_in_group("egg_system")


func _ready() -> void:
	if micro_event_controller != null and micro_event_controller.has_signal("choice_result_applied"):
		if not micro_event_controller.choice_result_applied.is_connected(_on_choice_result_applied):
			micro_event_controller.choice_result_applied.connect(_on_choice_result_applied)

	if bond_system != null and bond_system.has_signal("bond_changed"):
		if not bond_system.bond_changed.is_connected(_on_bond_changed):
			bond_system.bond_changed.connect(_on_bond_changed)

	if egg_system != null and egg_system.has_signal("egg_hatched"):
		if not egg_system.egg_hatched.is_connected(_on_egg_hatched):
			egg_system.egg_hatched.connect(_on_egg_hatched)

	if _is_egg_hatched():
		_transition_to_stage(STAGE_BABY)

	progression_updated.emit(get_lifecycle_snapshot())


func record_care_action(action_id: StringName) -> void:
	if not is_gameplay_unlocked():
		return

	match action_id:
		&"feed":
			_increment_counter("feed_count")
		&"cuddle":
			_increment_counter("play_session_count")
		&"clean":
			_increment_counter("clean_count")


func record_mini_game_result(_minigame_id: StringName, _success_level: StringName = &"standard") -> void:
	if not is_gameplay_unlocked():
		return

	_increment_counter("mini_game_count")


func get_lifecycle_snapshot() -> Dictionary:
	return {
		"current_stage": str(current_stage),
		"previous_stage": str(previous_stage),
		"is_gameplay_unlocked": is_gameplay_unlocked(),
		"counters": counters.duplicate(true),
		"requirements": _get_requirement_snapshot(),
	}


func _on_choice_result_applied(_event_id: StringName, _option_id: StringName, _result_data: Dictionary) -> void:
	if not is_gameplay_unlocked():
		return

	_increment_counter("personality_event_count")


func _on_bond_changed(_current_bond: float, _snapshot: Dictionary) -> void:
	if not is_gameplay_unlocked():
		return

	_try_advance_stage()


func _on_egg_hatched(_snapshot: Dictionary) -> void:
	_transition_to_stage(STAGE_BABY)


func _increment_counter(counter_name: String) -> void:
	var current_value := int(counters.get(counter_name, 0))
	counters[counter_name] = current_value + 1
	_try_advance_stage()
	progression_updated.emit(get_lifecycle_snapshot())


func _try_advance_stage() -> void:
	var next_stage := current_stage

	match current_stage:
		STAGE_EGG:
			if _is_egg_hatched():
				next_stage = STAGE_BABY
		STAGE_BABY:
			if _meets_baby_to_juvenile():
				next_stage = STAGE_JUVENILE
		STAGE_JUVENILE:
			if _meets_juvenile_to_adult():
				next_stage = STAGE_ADULT
		STAGE_ADULT:
			if _meets_adult_to_final_form():
				next_stage = STAGE_FINAL_FORM

	_transition_to_stage(next_stage)


func _meets_baby_to_juvenile() -> bool:
	return int(counters["feed_count"]) >= int(BABY_TO_JUVENILE_REQUIREMENTS["feed_count"]) \
		and int(counters["play_session_count"]) >= int(BABY_TO_JUVENILE_REQUIREMENTS["play_session_count"]) \
		and int(counters["personality_event_count"]) >= int(BABY_TO_JUVENILE_REQUIREMENTS["personality_event_count"])


func _meets_juvenile_to_adult() -> bool:
	var bond_snapshot := _get_bond_snapshot()
	return float(bond_snapshot.get("current_bond", 0.0)) >= float(JUVENILE_TO_ADULT_REQUIREMENTS["bond_threshold"]) \
		and int(counters["mini_game_count"]) >= int(JUVENILE_TO_ADULT_REQUIREMENTS["mini_game_count"])


func _meets_adult_to_final_form() -> bool:
	return int(counters["personality_event_count"]) >= int(ADULT_TO_FINAL_FORM_REQUIREMENTS["personality_event_count"]) \
		and int(counters["clean_count"]) >= int(ADULT_TO_FINAL_FORM_REQUIREMENTS["clean_count"]) \
		and int(counters["mini_game_count"]) >= int(ADULT_TO_FINAL_FORM_REQUIREMENTS["mini_game_count"])


func _get_bond_snapshot() -> Dictionary:
	if bond_system == null or not bond_system.has_method("get_bond_snapshot"):
		return {}
	return bond_system.get_bond_snapshot()


func is_gameplay_unlocked() -> bool:
	return current_stage != STAGE_EGG


func _is_egg_hatched() -> bool:
	if egg_system == null or not egg_system.has_method("get_egg_snapshot"):
		return true

	var snapshot: Dictionary = egg_system.get_egg_snapshot()
	return bool(snapshot.get("is_hatched", false))


func _transition_to_stage(next_stage: StringName) -> void:
	if next_stage == current_stage:
		return

	previous_stage = current_stage
	current_stage = next_stage
	var snapshot := get_lifecycle_snapshot()
	stage_changed.emit(previous_stage, current_stage, snapshot)
	progression_updated.emit(snapshot)


func _get_requirement_snapshot() -> Dictionary:
	var bond_snapshot := _get_bond_snapshot()
	return {
		"baby_to_juvenile": {
			"feed_remaining": max(0, int(BABY_TO_JUVENILE_REQUIREMENTS["feed_count"]) - int(counters["feed_count"])),
			"play_remaining": max(0, int(BABY_TO_JUVENILE_REQUIREMENTS["play_session_count"]) - int(counters["play_session_count"])),
			"personality_event_remaining": max(0, int(BABY_TO_JUVENILE_REQUIREMENTS["personality_event_count"]) - int(counters["personality_event_count"])),
		},
		"juvenile_to_adult": {
			"bond_remaining": max(0.0, float(JUVENILE_TO_ADULT_REQUIREMENTS["bond_threshold"]) - float(bond_snapshot.get("current_bond", 0.0))),
			"mini_game_remaining": max(0, int(JUVENILE_TO_ADULT_REQUIREMENTS["mini_game_count"]) - int(counters["mini_game_count"])),
		},
		"adult_to_final_form": {
			"personality_event_remaining": max(0, int(ADULT_TO_FINAL_FORM_REQUIREMENTS["personality_event_count"]) - int(counters["personality_event_count"])),
			"clean_remaining": max(0, int(ADULT_TO_FINAL_FORM_REQUIREMENTS["clean_count"]) - int(counters["clean_count"])),
			"mini_game_remaining": max(0, int(ADULT_TO_FINAL_FORM_REQUIREMENTS["mini_game_count"]) - int(counters["mini_game_count"])),
		},
	}
