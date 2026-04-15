extends Node
class_name PetIdleController

@export var pet_visual: CanvasItem
@export var pet_state_controller: PetStateController

@export var idle_interval_min: float = 2.5
@export var idle_interval_max: float = 5.0
@export var process_enabled: bool = true

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
	if pet_state_controller.current_state == PetStateController.STATE_SLEEPING:
		return false
	
	if pet_state_controller.current_state == PetStateController.STATE_CRITICAL:
		return false
	
	return true


func _trigger_idle() -> void:
	print("Idle trigger fired")
