extends Node

signal personality_changed(snapshot: Dictionary)
signal drift_applied(source: StringName, deltas: Dictionary, snapshot: Dictionary)

const TRAIT_ENERGY := &"energy"
const TRAIT_SOCIAL := &"social"
const TRAIT_EMPATHY := &"empathy"
const TRAIT_CHAOS := &"chaos"
const TRAIT_MATURITY := &"maturity"

const TRAIT_IDS := [
	TRAIT_ENERGY,
	TRAIT_SOCIAL,
	TRAIT_EMPATHY,
	TRAIT_CHAOS,
	TRAIT_MATURITY,
]

const DEFAULT_TRAIT_VALUE := 50.0
const MIN_TRAIT_VALUE := 0.0
const MAX_TRAIT_VALUE := 100.0
const LOW_NEED_THRESHOLD := 35.0
const STABLE_NEED_THRESHOLD := 70.0
const NEGLECT_CHECK_INTERVAL := 8.0

var traits: Dictionary = {}
var _neglect_timer := 0.0
var _last_snapshot: Dictionary = {}

@onready var need_system = get_tree().get_first_node_in_group("need_system")
@onready var micro_event_controller = get_tree().get_root().find_child("MicroEventController", true, false)


func _ready() -> void:
	for trait_id in TRAIT_IDS:
		traits[trait_id] = DEFAULT_TRAIT_VALUE

	if micro_event_controller != null and micro_event_controller.has_signal("choice_result_applied"):
		if not micro_event_controller.choice_result_applied.is_connected(_on_choice_result_applied):
			micro_event_controller.choice_result_applied.connect(_on_choice_result_applied)

	if need_system != null and need_system.has_signal("sleep_mode_changed"):
		if not need_system.sleep_mode_changed.is_connected(_on_sleep_mode_changed):
			need_system.sleep_mode_changed.connect(_on_sleep_mode_changed)

	_last_snapshot = get_personality_snapshot()


func _process(delta: float) -> void:
	if need_system == null or not need_system.has_method("get_needs_snapshot"):
		return

	_neglect_timer += delta
	if _neglect_timer < NEGLECT_CHECK_INTERVAL:
		return

	_neglect_timer = 0.0
	_evaluate_passive_drift()


func record_care_action(action_id: StringName) -> void:
	match action_id:
		&"feed":
			_apply_drift(&"care_feed", {
				TRAIT_EMPATHY: 1.2,
				TRAIT_MATURITY: 0.7,
			})
		&"cuddle":
			_apply_drift(&"care_cuddle", {
				TRAIT_EMPATHY: 1.8,
				TRAIT_SOCIAL: 1.0,
			})
		&"clean":
			_apply_drift(&"care_clean", {
				TRAIT_MATURITY: 1.2,
				TRAIT_EMPATHY: 0.6,
			})


func get_personality_snapshot() -> Dictionary:
	var snapshot := {
		"traits": {},
		"dominant_trait": "",
		"profile_tags": [],
	}

	for trait_id in TRAIT_IDS:
		snapshot["traits"][String(trait_id)] = traits.get(trait_id, DEFAULT_TRAIT_VALUE)

	snapshot["dominant_trait"] = String(_get_dominant_trait())
	snapshot["profile_tags"] = _build_profile_tags()
	return snapshot


func _on_choice_result_applied(event_id: StringName, option_id: StringName, result_data: Dictionary) -> void:
	var deltas: Dictionary = result_data.get("personality_effects", {})
	if deltas.is_empty():
		return

	_apply_drift(StringName("choice_%s_%s" % [event_id, option_id]), deltas)


func _on_sleep_mode_changed(is_sleeping: bool) -> void:
	if not is_sleeping:
		return

	_apply_drift(&"care_sleep", {
		TRAIT_MATURITY: 0.8,
		TRAIT_ENERGY: 0.4,
	})


func _evaluate_passive_drift() -> void:
	var needs_snapshot: Dictionary = need_system.get_needs_snapshot()
	var low_need_count := 0
	var stable_need_count := 0

	for need_id in ["hunger", "happiness", "hygiene", "sleep"]:
		var need_data: Dictionary = needs_snapshot.get(need_id, {})
		var current_value := float(need_data.get("current_value", DEFAULT_TRAIT_VALUE))
		if current_value <= LOW_NEED_THRESHOLD:
			low_need_count += 1
		if current_value >= STABLE_NEED_THRESHOLD:
			stable_need_count += 1

	if low_need_count >= 2:
		_apply_drift(&"passive_neglect", {
			TRAIT_SOCIAL: -0.8,
			TRAIT_EMPATHY: -0.6,
			TRAIT_CHAOS: 0.4,
		})
	elif stable_need_count == 4:
		_apply_drift(&"passive_stability", {
			TRAIT_MATURITY: 0.4,
			TRAIT_EMPATHY: 0.3,
		})


func _apply_drift(source: StringName, deltas: Dictionary) -> void:
	var changed := false

	for trait_id in deltas.keys():
		var normalized_trait := StringName(trait_id)
		if not traits.has(normalized_trait):
			continue

		var previous_value := float(traits[normalized_trait])
		var next_value := clampf(previous_value + float(deltas[trait_id]), MIN_TRAIT_VALUE, MAX_TRAIT_VALUE)
		if is_equal_approx(previous_value, next_value):
			continue

		traits[normalized_trait] = next_value
		changed = true

	if not changed:
		return

	_last_snapshot = get_personality_snapshot()
	drift_applied.emit(source, deltas.duplicate(true), _last_snapshot.duplicate(true))
	personality_changed.emit(_last_snapshot.duplicate(true))


func _get_dominant_trait() -> StringName:
	var dominant_trait := TRAIT_ENERGY
	var dominant_delta := -INF

	for trait_id in TRAIT_IDS:
		var delta := absf(float(traits.get(trait_id, DEFAULT_TRAIT_VALUE)) - DEFAULT_TRAIT_VALUE)
		if delta <= dominant_delta:
			continue
		dominant_delta = delta
		dominant_trait = trait_id

	return dominant_trait


func _build_profile_tags() -> Array:
	var tags: Array = []

	if float(traits[TRAIT_CHAOS]) >= 60.0:
		tags.append("chaotic")
	if float(traits[TRAIT_MATURITY]) >= 60.0:
		tags.append("grounded")
	if float(traits[TRAIT_SOCIAL]) >= 60.0:
		tags.append("social")
	if float(traits[TRAIT_EMPATHY]) >= 60.0:
		tags.append("warm")
	if float(traits[TRAIT_ENERGY]) >= 60.0:
		tags.append("lively")

	if tags.is_empty():
		tags.append("balanced")

	return tags
