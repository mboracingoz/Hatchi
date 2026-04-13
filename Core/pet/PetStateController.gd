extends Node

const STATE_NORMAL := &"normal"
const STATE_HUNGRY := &"hungry"
const STATE_DIRTY := &"dirty"
const STATE_SLEEPY := &"sleepy"
const STATE_SAD := &"sad"
const STATE_CRITICAL := &"critical"
const STATE_SLEEPING := &"sleeping"

@export var pet_area: Control
@export var state_label: Label
@export var sleep_label: Label

@export var feed_button: Button
@export var cuddle_button: Button
@export var clean_button: Button
@export var sleep_button: Button

const LOW_THRESHOLD := 35.0
const CRITICAL_THRESHOLD := 15.0

var current_state: StringName = STATE_NORMAL
var previous_state: StringName = STATE_NORMAL

var is_sleeping: bool = false
var sleep_label_base_position: Vector2
var sleep_tween: Tween
var sleep_label_center_position: Vector2
var sleep_label_move_range := Vector2(35, 18)
var rng := RandomNumberGenerator.new()

@export var need_system: Node


func _ready() -> void:
	if state_label != null:
		state_label.text = get_state_text(current_state)
		state_label.modulate = get_state_color(current_state)
	
	if sleep_label != null:
		sleep_label_base_position = sleep_label.position
	
	rng.randomize()

	if sleep_label != null:
		sleep_label_center_position = sleep_label.position
	
	update_action_buttons()
	update_pet_visual()
	update_sleep_label()

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
	update_action_buttons()
	update_pet_visual()
	update_sleep_label()
	
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

func update_action_buttons() -> void:
	if sleep_button != null:
		sleep_button.disabled = false
		sleep_button.text = "Wake" if is_sleeping else "Sleep"
	
	if feed_button != null:
		feed_button.disabled = is_sleeping
	
	if cuddle_button != null:
		cuddle_button.disabled = is_sleeping
	
	if clean_button != null:
		clean_button.disabled = is_sleeping

# TEMP DEBUG INPUTS
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		is_sleeping = not is_sleeping
		print("Sleeping toggled: ", is_sleeping)
		
		
		
		

func update_pet_visual() -> void:
	if pet_area == null:
		return
	
	if is_sleeping:
		pet_area.modulate = Color(1.143, 1.001, 2.879, 1.0)
	else:
		pet_area.modulate = Color(1,1,1)


func update_sleep_label() -> void:
	if sleep_label == null:
		return

	sleep_label.visible = is_sleeping
	
	if is_sleeping:
		play_sleep_label_animation()
	else:
		if sleep_tween != null:
			sleep_tween.kill()
			sleep_tween = null
		sleep_label.position = sleep_label_center_position
		sleep_label.scale = Vector2.ONE

func play_sleep_label_animation() -> void:
	if sleep_label == null:
		return

	if sleep_tween != null:
		sleep_tween.kill()

	_start_sleep_label_wander()


func _start_sleep_label_wander() -> void:
	if sleep_label == null or not is_sleeping:
		return

	var target_offset = Vector2(
		rng.randf_range(-sleep_label_move_range.x, sleep_label_move_range.x),
		rng.randf_range(-sleep_label_move_range.y, sleep_label_move_range.y)
	)

	var target_position = sleep_label_center_position + target_offset
	var target_scale = Vector2.ONE * rng.randf_range(0.95, 1.08)

	sleep_tween = create_tween()
	sleep_tween.set_trans(Tween.TRANS_SINE)
	sleep_tween.set_ease(Tween.EASE_IN_OUT)

	sleep_tween.tween_property(sleep_label, "position", target_position, 1.2)
	sleep_tween.parallel().tween_property(sleep_label, "scale", target_scale, 1.2)
	sleep_tween.finished.connect(_start_sleep_label_wander)
