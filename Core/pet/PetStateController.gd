extends Node

const STATE_NORMAL := &"normal"
const STATE_HUNGRY := &"hungry"
const STATE_DIRTY := &"dirty"
const STATE_SLEEPY := &"sleepy"
const STATE_SAD := &"sad"
const STATE_CRITICAL := &"critical"
const STATE_SLEEPING := &"sleeping"

@export var state_label: Label

const LOW_THRESHOLD := 35.0
const CRITICAL_THRESHOLD := 15.0

var current_state: StringName = STATE_NORMAL
var previous_state: StringName = STATE_NORMAL

var is_sleeping: bool = false

@export var need_system: Node


func _ready() -> void:
	if state_label != null:
		state_label.text = get_state_text(current_state)
		state_label.modulate = get_state_color(current_state)

func _process(_delta: float) -> void:
	if need_system == null or not ("needs" in need_system):
		return
	
	var new_state = calculate_state(need_system.needs)
	
	if new_state != current_state:
		previous_state = current_state
		current_state = new_state
		on_state_changed()

func calculate_state(needs: Dictionary) -> StringName:
	var hunger = needs.get("hunger").current_value
	var hygiene = needs.get("hygiene").current_value
	var happiness = needs.get("happiness").current_value
	var sleep = needs.get("sleep").current_value

	if hunger <= CRITICAL_THRESHOLD \
	or hygiene <= CRITICAL_THRESHOLD \
	or happiness <= CRITICAL_THRESHOLD \
	or sleep <= CRITICAL_THRESHOLD:
		return STATE_CRITICAL

	if hunger <= LOW_THRESHOLD:
		return STATE_HUNGRY

	if hygiene <= LOW_THRESHOLD:
		return STATE_DIRTY

	if sleep <= LOW_THRESHOLD:
		return STATE_SLEEPY

	if happiness <= LOW_THRESHOLD:
		return STATE_SAD
	
	if is_sleeping:
		return STATE_SLEEPING
	
	
	if needs.is_empty():
		return STATE_NORMAL
	
	return STATE_NORMAL

func on_state_changed():
	print("State changed: ", previous_state, " -> ", current_state)
	
	if state_label == null:
		return
	
	state_label.text = get_state_text(current_state)
	state_label.modulate = get_state_color(current_state)


func get_state_text(state: StringName) -> String:
	match state:
		STATE_NORMAL:
			return "Happy"
		STATE_HUNGRY:
			return "Hungry"
		STATE_DIRTY:
			return "Dirty"
		STATE_SLEEPY:
			return "Sleep"
		STATE_SAD:
			return "Needs Attention"
		STATE_CRITICAL:
			return "Critic"
		STATE_SLEEPING:
			return "Sleeping"
		_:
			return "Unknown"


func get_state_color(state: StringName) -> Color:
	match state:
		STATE_NORMAL:
			return Color(0.4, 1.0, 0.4) # yeşil
		STATE_HUNGRY:
			return Color(1.0, 0.7, 0.2) # turuncu
		STATE_DIRTY:
			return Color(0.6, 0.6, 0.6) # gri
		STATE_SLEEPY:
			return Color(0.5, 0.5, 1.0) # mavi
		STATE_SAD:
			return Color(0.7, 0.7, 1.0) # açık mavi
		STATE_CRITICAL:
			return Color(1.0, 0.2, 0.2) # kırmızı
		STATE_SLEEPING:
			return Color(0.3, 0.3, 0.6) # koyu mavi
		_:
			return Color.WHITE

func set_sleeping(value: bool) -> void:
	is_sleeping = true

func toggle_sleep() -> void:
	is_sleeping = not is_sleeping
	print("Sleeping toggled (button): ", is_sleeping)

# TEMP DEBUG INPUTS
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		is_sleeping = not is_sleeping
		print("Sleeping toggled: ", is_sleeping)
		
		
		
		
