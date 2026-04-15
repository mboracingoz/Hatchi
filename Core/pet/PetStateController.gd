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
@export var pet_visual: CanvasItem


@export var feed_button: Button
@export var cuddle_button: Button
@export var clean_button: Button
@export var sleep_button: Button

const LOW_THRESHOLD := 35.0
const CRITICAL_THRESHOLD := 15.0

var current_state: StringName = STATE_NORMAL
var previous_state: StringName = STATE_NORMAL

var sleep_label_base_position: Vector2
var sleep_label_center_position: Vector2
var sleep_label_move_range := Vector2(35, 18)
var rng := RandomNumberGenerator.new()



var sleep_tween: Tween
var pet_visual_tween: Tween
var breathing_tween: Tween
var critical_tween: Tween
var is_sleeping: bool = false

#Action Tweens
var action_tween: Tween

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
	update_pet_state_visual()
	update_pet_state_reaction()

func _process(_delta: float) -> void:
	if need_system == null or not ("needs" in need_system):
		return
	
	var new_state = calculate_state(need_system.needs)
	
	if new_state != current_state:
		previous_state = current_state
		current_state = new_state
		on_state_changed()

func calculate_state(needs: Dictionary) -> StringName:
	if needs.is_empty():
		return STATE_NORMAL

	var hunger = needs.get("hunger").current_value
	var hygiene = needs.get("hygiene").current_value
	var happiness = needs.get("happiness").current_value
	var sleep = needs.get("sleep").current_value

	# Sleeping can override everything except critical hunger.
	if is_sleeping and hunger > CRITICAL_THRESHOLD:
		return STATE_SLEEPING

	# Critical states
	if hunger <= CRITICAL_THRESHOLD \
	or hygiene <= CRITICAL_THRESHOLD \
	or happiness <= CRITICAL_THRESHOLD \
	or sleep <= CRITICAL_THRESHOLD:
		return STATE_CRITICAL

	# Low states
	if hunger <= LOW_THRESHOLD:
		return STATE_HUNGRY

	if hygiene <= LOW_THRESHOLD:
		return STATE_DIRTY

	if sleep <= LOW_THRESHOLD:
		return STATE_SLEEPY

	if happiness <= LOW_THRESHOLD:
		return STATE_SAD

	return STATE_NORMAL


func on_state_changed():
	print("State changed: ", previous_state, " -> ", current_state)

	update_action_buttons()
	update_pet_visual()
	update_sleep_label()
	update_pet_state_visual()
	update_pet_state_reaction()
	update_state_animations()

	if state_label != null:
		state_label.text = get_state_text(current_state)
		state_label.modulate = get_state_color(current_state)

func update_action_buttons() -> void:
	if sleep_button == null:
		sleep_button.disabled = false
		sleep_button.text = "Wake" if is_sleeping else "Sleep"
		
	if feed_button != null:
		feed_button.disabled = is_sleeping
	
	if cuddle_button != null:
		cuddle_button.disabled = is_sleeping
	
	if clean_button != null:
		clean_button.disabled = is_sleeping

func get_state_text(state: StringName) -> String:
	match state:
		STATE_NORMAL:
			return "Happy"
		STATE_HUNGRY:
			return "Hungry"
		STATE_DIRTY:
			return "Dirty"
		STATE_SLEEPY:
			return "Sleepy"
		STATE_SAD:
			return "Needs Attention"
		STATE_CRITICAL:
			return "Critical!"
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
	is_sleeping = value


func toggle_sleep() -> void:
	if need_system == null or not ("needs" in need_system):
		return

	var hunger = need_system.needs["hunger"].current_value

	# Wake up if already sleeping
	if is_sleeping:
		is_sleeping = false
		print("Woke up")
		return

	# Cannot sleep if hunger is critical
	if hunger <= CRITICAL_THRESHOLD:
		print("Too hungry to sleep")
		return

	is_sleeping = true
	print("Sleeping toggled (button): ", is_sleeping)


func update_state_animations() -> void:
	stop_breathing_animation()
	stop_critical_pulse()

	if current_state == STATE_SLEEPING:
		start_breathing_animation()
	elif current_state == STATE_CRITICAL:
		start_critical_pulse()

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


func update_pet_state_visual() -> void:
	if pet_visual == null:
		return

	match current_state:
		STATE_NORMAL:
			pet_visual.modulate = Color(1, 1, 1, 1)
		STATE_HUNGRY:
			pet_visual.modulate = Color(1.0, 0.92, 0.92, 1)
		STATE_DIRTY:
			pet_visual.modulate = Color(0.3, 0.3, 0.3, 1)
		STATE_SLEEPY:
			pet_visual.modulate = Color(0.88, 0.88, 1.0, 1)
		STATE_SAD:
			pet_visual.modulate = Color(0.9, 0.9, 1.0, 1)
		STATE_CRITICAL:
			pet_visual.modulate = Color(0.45, 0.0, 0.106, 1.0)
		STATE_SLEEPING:
			pet_visual.modulate = Color(0.75, 0.75, 0.9, 1)


func update_pet_state_reaction() -> void:
	if pet_visual == null:
		return

	if pet_visual_tween != null:
		pet_visual_tween.kill()

	var target_scale := Vector2.ONE

	match current_state:
		STATE_NORMAL:
			target_scale = Vector2(1.0, 1.0)
		STATE_HUNGRY:
			target_scale = Vector2(0.96, 0.96)
		STATE_DIRTY:
			target_scale = Vector2(0.94, 0.94)
		STATE_SLEEPY:
			target_scale = Vector2(0.95, 0.95)
		STATE_SAD:
			target_scale = Vector2(0.93, 0.93)
		STATE_CRITICAL:
			target_scale = Vector2(0.90, 0.90)
		STATE_SLEEPING:
			target_scale = Vector2(0.92, 0.92)

	pet_visual_tween = create_tween()
	pet_visual_tween.set_trans(Tween.TRANS_SINE)
	pet_visual_tween.set_ease(Tween.EASE_OUT)
	pet_visual_tween.tween_property(pet_visual, "scale", target_scale, 0.18)

func start_breathing_animation() -> void:
	if pet_visual == null:
		return
	
	if breathing_tween != null:
		breathing_tween.kill()
	
	breathing_tween = create_tween()
	breathing_tween.set_loops()
	
	breathing_tween.set_trans(Tween.TRANS_SINE)
	breathing_tween.set_ease(Tween.EASE_IN_OUT)
	
	breathing_tween.tween_property(pet_visual, "scale", Vector2(0.95, 0.95), 1.2)
	breathing_tween.tween_property(pet_visual, "scale", Vector2(1.0, 1.0), 1.2)


func stop_breathing_animation() -> void:
	if breathing_tween != null:
		breathing_tween.kill()
		breathing_tween = null
	
	if pet_visual != null:
		pet_visual.scale = Vector2.ONE

func start_critical_pulse() -> void:
	if pet_visual == null:
		return
	
	if critical_tween != null:
		critical_tween.kill()
	
	
	critical_tween = create_tween()
	critical_tween.set_loops()
	
	critical_tween.set_trans(Tween.TRANS_SINE)
	critical_tween.set_ease(Tween.EASE_IN_OUT)
	
	critical_tween.tween_property(pet_visual, "scale", Vector2(1.08, 1.08), 0.25)
	critical_tween.tween_property(pet_visual, "scale", Vector2(0.92, 0.92), 0.25)

func stop_critical_pulse() -> void:
	if critical_tween != null:
		critical_tween.kill()
		critical_tween = null


func play_action_reaction(strength: float = 1.1) -> void:
	if pet_visual == null:
		return
	
	if action_tween != null:
		action_tween.kill()
	
	action_tween = create_tween()
	action_tween.set_trans(Tween.TRANS_BACK)
	action_tween.set_ease(Tween.EASE_IN_OUT)
	
	action_tween.tween_property(pet_visual, "scale", Vector2(strength, strength), 0.12)
	action_tween.tween_property(pet_visual, "scale", Vector2.ONE, 0.18)
