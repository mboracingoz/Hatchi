extends Node
class_name PetMicroEventController

signal micro_event_triggered(event_data: Dictionary)


func trigger_random_event() -> void:
	var event_data := _pick_event()
	print("Micro event emitted: ", event_data)
	micro_event_triggered.emit(event_data)

func _pick_event() -> Dictionary:
	var events := [
		#{
			#"id": &"idle_think",
			#"type": &"observe"
		#},
		#{
			#"id": &"idle_notice",
			#"type": &"observe"
		#},
		#{
			#"id": &"idle_love",
			#"type": &"mood"
		#},
		{
			"id": &"question_simple",
			"type": &"choice"
		}
	]

	return events.pick_random()
