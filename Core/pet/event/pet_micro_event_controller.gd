extends Node
class_name PetMicroEventController

signal micro_event_triggered(event_data: Dictionary)
signal choice_result_applied(event_id: StringName, option_id: StringName, result_data: Dictionary)

const DEFAULT_EVENTS := [
	{
		"id": &"question_simple",
		"type": &"choice",
		"question": "What should we do together?",
		"options": [
			{
				"id": &"option_a",
				"text": "Play a little",
				"result": {
					"feedback": "That was fun!",
					"need_effects": {
						"happiness": 10.0,
						"sleep": -4.0
					},
					"personality_effects": {
						"energy": 3.0,
						"social": 2.0,
						"chaos": 1.0
					},
					"reaction": {
						"scale": 1.08,
						"profile": "playful"
					}
				}
			},
			{
				"id": &"option_b",
				"text": "Take a short rest",
				"result": {
					"feedback": "Feeling better...",
					"need_effects": {
						"sleep": 10.0,
						"happiness": 2.0
					},
					"personality_effects": {
						"maturity": 2.5,
						"empathy": 1.0
					},
					"reaction": {
						"scale": 0.96,
						"profile": "calm"
					}
				}
			}
		]
	},
	{
		"id": &"music_moment",
		"type": &"choice",
		"question": "The pet is humming. How do you react?",
		"options": [
			{
				"id": &"option_a",
				"text": "Applaud loudly",
				"result": {
					"feedback": "A proud little bow!",
					"need_effects": {
						"happiness": 8.0
					},
					"personality_effects": {
						"social": 2.5,
						"empathy": 1.5
					},
					"reaction": {
						"scale": 1.1,
						"profile": "playful"
					}
				}
			},
			{
				"id": &"option_b",
				"text": "Suggest bedtime",
				"result": {
					"feedback": "A sleepy nod...",
					"need_effects": {
						"sleep": 8.0,
						"happiness": -2.0
					},
					"personality_effects": {
						"maturity": 2.0,
						"empathy": 0.8
					},
					"reaction": {
						"scale": 0.95,
						"profile": "calm"
					}
				}
			}
		]
	}
]

var _event_catalog: Dictionary = {}
var _last_event_data: Dictionary = {}
var _last_choice_result: Dictionary = {}

func _ready() -> void:
	_build_catalog()

func trigger_random_event() -> void:
	var event_data := _pick_event()
	_last_event_data = event_data.duplicate(true)
	print("Micro event emitted: ", event_data)
	micro_event_triggered.emit(event_data)

func trigger_event(event_id: StringName) -> bool:
	var event_data := get_event_data(event_id)
	if event_data.is_empty():
		return false

	_last_event_data = event_data.duplicate(true)
	print("Micro event emitted: ", event_data)
	micro_event_triggered.emit(event_data)
	return true

func get_event_data(event_id: StringName) -> Dictionary:
	var event_data: Dictionary = _event_catalog.get(String(event_id), {})
	if event_data.is_empty():
		return {}

	return event_data.duplicate(true)

func apply_choice_result(event_id: StringName, option_id: StringName) -> Dictionary:
	var event_data := get_event_data(event_id)
	if event_data.is_empty():
		return {}

	for option in event_data.get("options", []):
		if StringName(option.get("id", &"")) != option_id:
			continue

		var result_data: Dictionary = option.get("result", {}).duplicate(true)
		_last_choice_result = {
			"event_id": str(event_id),
			"option_id": str(option_id),
			"result": result_data
		}
		choice_result_applied.emit(event_id, option_id, result_data)
		return result_data

	return {}

func get_last_event_snapshot() -> Dictionary:
	return {
		"last_event": _last_event_data,
		"last_choice_result": _last_choice_result
	}

func _pick_event() -> Dictionary:
	var events: Array = _event_catalog.values()
	if events.is_empty():
		return {}

	return events.pick_random().duplicate(true)

func _build_catalog() -> void:
	_event_catalog.clear()
	for event_data in DEFAULT_EVENTS:
		_event_catalog[String(event_data.get("id", &""))] = event_data.duplicate(true)
