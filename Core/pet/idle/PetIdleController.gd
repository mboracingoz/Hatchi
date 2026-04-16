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

var _idle_tween: Tween
var _is_idle_playing: bool = false

#TİMER
var _idle_timer: float = 0.0
var _current_idle_interval: float = 0.0

func _ready() -> void:
	randomize()
	_reset_idle_timer()


func _reset_idle_timer() -> void:
	_current_idle_interval = randf_range(idle_interval_min, idle_interval_max)
	_idle_timer = 0.0


func _process(delta: float) -> void:
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
	
	if pet_visual == null or pet_state_controller == null:
		return false
	
	if pet_state_controller.current_state != PetStateController.STATE_NORMAL:
		return false
	
	return true


func _trigger_idle() -> void:
	if pet_visual == null:
		return
	
	if _idle_tween != null:
		_idle_tween.kill()
	
	_is_idle_playing = true
	
	var roll := randf()

	if roll < 0.50:
		_play_idle_pulse()
	elif roll < 0.85:
		_play_idle_squish()
	else:
		_play_idle_look()

func _on_idle_finished() -> void:
	_is_idle_playing = false
	_idle_tween = null
	
	if pet_visual != null:
		pet_visual.scale = Vector2.ONE

func _play_idle_pulse() -> void:
	_idle_tween = create_tween()
	_idle_tween.set_trans(Tween.TRANS_SINE)
	_idle_tween.set_ease(Tween.EASE_IN_OUT)

	_idle_tween.tween_property(
		pet_visual,
		"scale",
		Vector2.ONE * idle_pulse_scale_min,
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

	var look_scale = Vector2(0.94 * look_direction, 1.0)

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
