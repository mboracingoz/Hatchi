extends Node
class_name PetIdleController

@export var pet_visual: CanvasItem
@export var pet_state_controller: PetStateController
@export var micro_event_controller: PetMicroEventController
@export var choice_panel_controller: ChoicePanelController

@export var feedback_label: Label

@export var idle_interval_min: float = 2.5
@export var idle_interval_max: float = 5.0
@export var process_enabled: bool = true

@export var need_system: Node

#TWEEN
@export var idle_pulse_scale_min: float = 1.02
@export var idle_pulse_scale_max: float = 1.053
@export  var idle_pulse_duration: float = 0.22
@export var idle_squish_duration: float = 0.28
@export var idle_look_duration: float = 0.20
@export var idle_interval_jitter: float = 0.8
@export var idle_self_event_chance: float = 0.4
@export var idle_event_label: RichTextLabel
@onready var egg_system = get_tree().get_first_node_in_group("egg_system")
	
var _idle_tween: Tween
var _idle_event_tween: Tween
var _is_idle_playing: bool = false
var _last_idle_type: StringName = &""
var _idle_event_start_pos: Vector2 = Vector2.ZERO

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
	
	if idle_event_label != null:
		_idle_event_start_pos = idle_event_label.position
		idle_event_label.visible = false
	
	if micro_event_controller != null:
		if not micro_event_controller.micro_event_triggered.is_connected(_on_micro_event_triggered):
			micro_event_controller.micro_event_triggered.connect(_on_micro_event_triggered)
	
	if choice_panel_controller != null:
		if not choice_panel_controller.choice_selected.is_connected(_on_choice_selected):
			choice_panel_controller.choice_selected.connect(_on_choice_selected)

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

	if egg_system != null and egg_system.has_method("is_gameplay_unlocked") and not bool(egg_system.is_gameplay_unlocked()):
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

	if _idle_event_tween != null:
		_idle_event_tween.kill()
		_idle_event_tween = null

	var symbol = _idle_event_symbols.pick_random()
	
	if micro_event_controller != null:
		micro_event_controller.trigger_random_event()
	
	_show_idle_event(symbol)

	var fade_in_duration := 0.18
	var visible_hold_duration := 0.30
	var fade_out_duration := 1.25
	var float_offset := -14.0
	var start_scale := Vector2(0.92, 0.92)

	if symbol.find("!") != -1:
		fade_in_duration = 0.14
		visible_hold_duration = 0.22
		fade_out_duration = 1.05
		float_offset = -12.0
		start_scale = Vector2(0.88, 0.88)

	elif symbol.find("❤") != -1:
		fade_in_duration = 0.20
		visible_hold_duration = 0.34
		fade_out_duration = 1.40
		float_offset = -16.0
		start_scale = Vector2(0.95, 0.95)

	var start_pos = _idle_event_start_pos
	var end_pos = start_pos + Vector2(0, float_offset)

	idle_event_label.position = start_pos
	idle_event_label.visible = true
	idle_event_label.modulate.a = 0.0
	idle_event_label.scale = start_scale

	_idle_event_tween = create_tween()
	var t = _idle_event_tween

	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_OUT)

	t.tween_property(
		idle_event_label,
		"modulate:a",
		1.0,
		fade_in_duration
	)

	t.parallel().tween_property(
		idle_event_label,
		"scale",
		Vector2.ONE,
		fade_in_duration
	)

	t.tween_interval(visible_hold_duration)

	t.parallel().tween_property(
		idle_event_label,
		"position",
		end_pos,
		fade_out_duration
	)

	t.parallel().tween_property(
		idle_event_label,
		"modulate:a",
		0.0,
		fade_out_duration
	)

	t.tween_callback(func():
		idle_event_label.visible = false
		idle_event_label.position = _idle_event_start_pos
		idle_event_label.scale = Vector2.ONE
		idle_event_label.modulate.a = 1.0
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
	
	if _idle_event_tween != null:
		_idle_event_tween.kill()
		_idle_event_tween = null
	
	if idle_event_label != null:
		idle_event_label.visible = false
		idle_event_label.position = idle_event_label.position
		idle_event_label.scale = Vector2.ONE
		idle_event_label.modulate.a = 1.0


func _show_idle_event(text: String) -> void:
	if idle_event_label == null:
		return

	idle_event_label.clear()
	idle_event_label.append_text(text)
	idle_event_label.visible = true
	idle_event_label.modulate.a = 1.0
	idle_event_label.scale = Vector2(0.92, 0.92)

func _on_micro_event_triggered(event_data: Dictionary) -> void:
	if not _is_gameplay_unlocked():
		return

	var event_type: StringName = event_data.get("type", &"observe")

	match event_type:
		&"observe":
			_handle_observe_event(event_data)
		&"mood":
			_handle_mood_event(event_data)
		&"choice":
			_handle_choice_event(event_data)


func _handle_observe_event(event_data: Dictionary) -> void:
	var event_id: StringName = event_data.get("id", &"")
	print("OBSERVE EVENT:", event_id)


func _handle_mood_event(event_data: Dictionary) -> void:
	var event_id: StringName = event_data.get("id", &"")
	print("MOOD EVENT:", event_id)


func _handle_choice_event(event_data: Dictionary) -> void:
	if not _is_gameplay_unlocked():
		return

	var event_id: StringName = event_data.get("id", &"")
	print("CHOICE EVENT:", event_id)

	stop_idle_immediately()

	if choice_panel_controller == null:
		print("ChoicePanelController is NULL")
		return

	choice_panel_controller.show_choice(event_data)


func _is_gameplay_unlocked() -> bool:
	if egg_system == null or not egg_system.has_method("is_gameplay_unlocked"):
		return true

	return bool(egg_system.is_gameplay_unlocked())

func _on_choice_selected(event_id: StringName, option_id: StringName) -> void:
	if micro_event_controller == null:
		return

	var result_data := micro_event_controller.apply_choice_result(event_id, option_id)
	if result_data.is_empty():
		return

	_apply_choice_result(event_id, option_id, result_data)

func _apply_choice_result(event_id: StringName, option_id: StringName, result_data: Dictionary) -> void:
	print("Choice result: ", event_id, " / ", option_id, " -> ", result_data)

	_apply_need_effects(result_data.get("need_effects", {}))
	_play_choice_reaction(result_data.get("reaction", {}))
	_show_feedback(str(result_data.get("feedback", "")))

func _apply_need_effects(need_effects: Dictionary) -> void:
	if need_system == null:
		return

	for need_id in need_effects.keys():
		var amount := float(need_effects[need_id])
		if need_system.has_method("add_%s" % need_id):
			need_system.call("add_%s" % need_id, amount)
			continue

		if need_system.has_method("set_need_value"):
			var snapshot: Dictionary = need_system.get_needs_snapshot()
			var current_need: Dictionary = snapshot.get(String(need_id), {})
			var current_value := float(current_need.get("current_value", 0.0))
			need_system.set_need_value(String(need_id), current_value + amount)

func _play_choice_reaction(reaction_data: Dictionary) -> void:
	if pet_visual == null:
		return

	var scale := float(reaction_data.get("scale", 1.0))
	var profile := str(reaction_data.get("profile", "calm"))
	var tween := create_tween()

	if profile == "playful":
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
	else:
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(pet_visual, "scale", Vector2.ONE * scale, 0.14)
	tween.tween_property(pet_visual, "scale", Vector2.ONE, 0.18)

func _show_feedback(text: String) -> void:
	if feedback_label == null:
		return

	feedback_label.text = text
	feedback_label.visible = true
	feedback_label.modulate.a = 1.0

	var tween := create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(feedback_label, "modulate:a", 0.0, 0.4)
	tween.finished.connect(func():
		feedback_label.visible = false
	)
