extends Node
class_name PetMicroEventController

signal  micro_event_triggered(event_id: StringName)


func trigger_random_event() -> void:
	var event_id: StringName = _pick_event()
	print("Micro event emitted: ", event_id)
	micro_event_triggered.emit(event_id)

func _pick_event() -> StringName:
	var events := [
	&"idle_think",
	&"idle_notice",
	&"idle_love"
	]
	
	return events.pick_random()
