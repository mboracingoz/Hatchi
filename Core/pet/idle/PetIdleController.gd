extends Node
class_name PetIdleController

@export var pet_visual: CanvasItem
@export var pet_state_controller: PetStateController

@export var idle_interval_min: float = 2.5
@export var idle_interval_max: float = 5.0
@export var process_enabled: bool = true

#TWEEN
@export var idle_pulse_scale_min: float = 1.02
@export var idle_pulse_scale_max: float = 1.053
@export  var idle_pulse_duration: float = 0.22
@export var idle_squish_duration: float = 0.28
@export var idle_look_duration: float = 0.20
@export var idle_interval_jitter: float = 0.8
@export var idle_self_event_chance: float = 0.4
@export var idle_event_label: RichTextLabel
	
var _idle_tween: Tween
var _is_idle_playing: bool = false
var _last_idle_type: StringName = &""

var _idle_event_symbols := [
	"[color=green]...[/color]",
	"[color=yellow]![/color]",
	"[color=red]❤[/color]"
]

#TİMER
@export var idle_cooldown_after_action: float = 2.0
var _idle_cooldown_timer: float = 0.0
var _idle_timer: float = 0.0
var _current_idle_interval: float = 0.0

func _ready() -> void:
	randomize()
	_reset_idle_timer()


func _reset_idle_timer() -> void:
	var base = randf_range(idle_interval_min, idle_interval_max)
	var jitter = randf_range(-idle_interval_jitter, idle_interval_jitter)

	_current_idle_interval = max(0.5, base + jitter)
	_idle_timer = 0.0


func _process(delta: float) -> void:
	if _idle_cooldown_timer > 0.0:
		_idle_cooldown_timer -= delta
	
	if not process_enabled:
		return
	
	if pet_visual == null or pet_state_controller == null:
		return
	
	if not _can_run_idle():
		_reset_idle_timer()
		return
	
	_idle_timer += delta
	
	if _idle_timer >= _current_idle_interval:
		_trigger_idle()
		_reset_idle_timer()


func _can_run_idle() -> bool:
	if _is_idle_playing:
		return false
	
	if _idle_cooldown_timer > 0.0:
		return false
	
	if pet_visual == null or pet_state_controller == null:
		return false
	
	if pet_state_controller.current_state == PetStateController.STATE_SLEEPING:
		return false

	if pet_state_controller.current_state == PetStateController.STATE_CRITICAL:
		return false
	
	return true


func _trigger_idle() -> void:
	if pet_visual == null:
		return
	
	if _idle_tween != null:
		_idle_tween.kill()
		_idle_tween = null
	
	var roll := randf()

	# Rare self-event hook
	if roll < idle_self_event_chance:
		_trigger_idle_event()
		return

	_is_idle_playing = true
	
	var selected_idle: StringName = &"pulse"
	
	if roll < 0.70:
		selected_idle = &"pulse"
	elif roll < 0.92:
		selected_idle = &"squish"
	else:
		selected_idle = &"look"
	
	if selected_idle == _last_idle_type:
		if selected_idle == &"pulse":
			selected_idle = &"squish"
		elif selected_idle == &"squish":
			selected_idle = &"pulse"
	
	_last_idle_type = selected_idle
	
	match selected_idle:
		&"pulse":
			_play_idle_pulse()
		&"squish":
			_play_idle_squish()
		&"look":
			_play_idle_look()
func _on_idle_finished() -> void:
	_is_idle_playing = false
	_idle_tween = null
	
	if pet_visual != null:
		pet_visual.scale = Vector2.ONE

func _play_idle_pulse() -> void:
	var random_scale = randf_range(idle_pulse_scale_min, idle_pulse_scale_max)
	var strength = _get_state_idle_strength()
	random_scale = lerp(1.0, random_scale, strength)
	_idle_tween = create_tween()
	_idle_tween.set_trans(Tween.TRANS_SINE)
	_idle_tween.set_ease(Tween.EASE_IN_OUT)

	_idle_tween.tween_property(
		pet_visual,
		"scale",
		Vector2.ONE * random_scale,
		idle_pulse_duration
	)
	_idle_tween.tween_property(
		pet_visual,
		"scale",
		Vector2.ONE,
		idle_pulse_duration
	)

	_idle_tween.finished.connect(_on_idle_finished)

func _play_idle_squish() -> void:
	var x = randf_range(1.08, 1.14)
	var y = randf_range(0.86, 0.92)
	var strength = _get_state_idle_strength()

	x = lerp(1.0, x, strength)
	y = lerp(1.0, y, strength)
	var squish_scale = Vector2(x, y)
	_idle_tween = create_tween()
	_idle_tween.set_trans(Tween.TRANS_SINE)
	_idle_tween.set_ease(Tween.EASE_IN_OUT)


	_idle_tween.tween_property(
		pet_visual,
		"scale",
		squish_scale,
		idle_squish_duration
	)
	_idle_tween.tween_property(
		pet_visual,
		"scale",
		Vector2.ONE,
		idle_squish_duration
	)

	_idle_tween.finished.connect(_on_idle_finished)


func _play_idle_look() -> void:
	_idle_tween = create_tween()
	_idle_tween.set_trans(Tween.TRANS_SINE)
	_idle_tween.set_ease(Tween.EASE_IN_OUT)

	var look_direction := 1.0
	if randf() < 0.5:
		look_direction = -1.0

	var strength = _get_state_idle_strength()
	var look_x = lerp(1.0, 0.94, strength) * look_direction
	var look_scale = Vector2(look_x, 1.0)

	_idle_tween.tween_property(
		pet_visual,
		"scale",
		look_scale,
		idle_look_duration
	)
	_idle_tween.tween_property(
		pet_visual,
		"scale",
		Vector2.ONE,
		idle_look_duration
	)

	_idle_tween.finished.connect(_on_idle_finished)

func notify_action_performed() -> void:
	_idle_cooldown_timer = idle_cooldown_after_action


func _trigger_idle_event() -> void:
	if idle_event_label == null:
		return

	print("Pet self event triggered")

	var symbol = _idle_event_symbols.pick_random()
	_show_idle_event(symbol)

	var fade_in_duration := 0.18
	var visible_hold_duration := 0.30
	var fade_out_duration := 1.25

	if symbol.find("!") != -1:
		fade_out_duration = 1.35
	elif symbol.find("❤") != -1:
		fade_out_duration = 1.45

	var start_pos = idle_event_label.position
	var end_pos = start_pos + Vector2(0, -14)

	idle_event_label.visible = true
	idle_event_label.modulate.a = 0.0
	idle_event_label.position = start_pos

	var bubble_tween = create_tween()
	bubble_tween.set_trans(Tween.TRANS_SINE)
	bubble_tween.set_ease(Tween.EASE_OUT)

	# 1) Fade in
	bubble_tween.tween_property(
		idle_event_label,
		"modulate:a",
		1.0,
		fade_in_duration
	)

	bubble_tween.tween_interval(visible_hold_duration)

	bubble_tween.parallel().tween_property(
		idle_event_label,
		"position",
		end_pos,
		fade_out_duration
	)

	bubble_tween.parallel().tween_property(
		idle_event_label,
		"modulate:a",
		0.0,
		fade_out_duration
	)

	bubble_tween.tween_callback(func():
		idle_event_label.visible = false
		idle_event_label.position = start_pos
	)

func _get_state_idle_strength() -> float:
	match pet_state_controller.current_state:
		PetStateController.STATE_NORMAL:
			return 1.0
		pet_state_controller.STATE_HUNGRY:
			return 0.7
		pet_state_controller.STATE_SAD:
			return 0.6
		pet_state_controller.STATE_SLEEPY:
			return 1.2
		_:
			return 0.5

func stop_idle_immediately() -> void:
	if _idle_tween != null:
		_idle_tween.kill()
		_idle_tween = null
	
	_is_idle_playing = false
	
	if pet_visual != null:
		pet_visual.scale = Vector2.ONE


func _show_idle_event(text: String) -> void:
	if idle_event_label == null:
		return

	idle_event_label.clear()
	idle_event_label.append_text(text)
	idle_event_label.visible = true
	idle_event_label.modulate.a = 1.0
	idle_event_label.scale = Vector2.ONE
