extends Node
class_name PetIdleController

@export var pet_visual: CanvasItem
@export var pet_state_controller: PetStateController

@export var idle_interval_min: float = 2.5
@export var idle_interval_max: float = 5.0
@export var process_enabled: bool = true

#TWEEN
@export var idle_pulse_scale: float = 1.03
@export  var idle_pulse_duration: float = 0.22

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
	
	_idle_tween = create_tween()
	_idle_tween.set_trans(Tween.TRANS_SINE)
	_idle_tween.set_ease(Tween.EASE_IN_OUT)
	
	_idle_tween.tween_property(
		pet_visual,
		"scale",
		Vector2.ONE * idle_pulse_scale,
		idle_pulse_duration
	)
	_idle_tween.tween_property(
		pet_visual,
		"scale",
		Vector2.ONE,
		idle_pulse_duration
	)
	_idle_tween.finished.connect(_on_idle_finished)

func _on_idle_finished() -> void:
	_is_idle_playing = false
	_idle_tween = null
	
	if pet_visual != null:
		pet_visual.scale = Vector2.ONE
