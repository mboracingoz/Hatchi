extends Node

signal egg_updated(snapshot: Dictionary)
signal egg_hatched(snapshot: Dictionary)

const TIER_COMMON := &"common"
const TIER_UNCOMMON := &"uncommon"
const TIER_RARE := &"rare"
const TIER_LEGENDARY := &"legendary"

const BASE_HATCH_DURATION_SECONDS := {
	TIER_COMMON: 120.0,
	TIER_UNCOMMON: 180.0,
	TIER_RARE: 240.0,
	TIER_LEGENDARY: 360.0,
}

const TAP_ACCELERATION_LIMIT_RATIO := 0.10
const TAP_PROGRESS_SECONDS := 3.0
const UPDATE_INTERVAL_SECONDS := 0.25

var rarity_tier: StringName = TIER_COMMON
var hatch_duration_seconds: float = 120.0
var time_remaining_seconds: float = 120.0
var tap_acceleration_used: float = 0.0
var crack_count: int = 0
var is_hatched: bool = false
var _hatch_deadline_msec: int = 0
var _update_timer: Timer


func _ready() -> void:
	_apply_rarity_defaults()
	_update_timer = Timer.new()
	_update_timer.wait_time = UPDATE_INTERVAL_SECONDS
	_update_timer.one_shot = false
	_update_timer.autostart = false
	add_child(_update_timer)
	if not _update_timer.timeout.is_connected(_on_update_timer_timeout):
		_update_timer.timeout.connect(_on_update_timer_timeout)
	_update_timer.start()
	_emit_update()


func tap_egg() -> Dictionary:
	_sync_time_remaining()
	if is_hatched:
		return get_egg_snapshot()

	var tap_budget := hatch_duration_seconds * TAP_ACCELERATION_LIMIT_RATIO
	if tap_acceleration_used < tap_budget:
		var applied := minf(TAP_PROGRESS_SECONDS, tap_budget - tap_acceleration_used)
		time_remaining_seconds = maxf(0.0, time_remaining_seconds - applied)
		tap_acceleration_used += applied
		_refresh_deadline_from_remaining()

	crack_count += 1
	if is_equal_approx(time_remaining_seconds, 0.0):
		_finish_hatching()
		return get_egg_snapshot()

	_emit_update()
	return get_egg_snapshot()


func force_hatch() -> void:
	if is_hatched:
		return

	time_remaining_seconds = 0.0
	_finish_hatching()


func get_egg_snapshot() -> Dictionary:
	_sync_time_remaining()
	return {
		"rarity_tier": str(rarity_tier),
		"hatch_duration_seconds": hatch_duration_seconds,
		"time_remaining_seconds": time_remaining_seconds,
		"progress_ratio": _get_progress_ratio(),
		"tap_acceleration_used": tap_acceleration_used,
		"tap_acceleration_limit": hatch_duration_seconds * TAP_ACCELERATION_LIMIT_RATIO,
		"crack_count": crack_count,
		"is_hatched": is_hatched,
	}


func is_gameplay_unlocked() -> bool:
	return is_hatched


func _apply_rarity_defaults() -> void:
	hatch_duration_seconds = float(BASE_HATCH_DURATION_SECONDS.get(rarity_tier, 120.0))
	time_remaining_seconds = hatch_duration_seconds
	_refresh_deadline_from_remaining()


func _finish_hatching() -> void:
	if is_hatched:
		return

	is_hatched = true
	time_remaining_seconds = 0.0
	if _update_timer != null:
		_update_timer.stop()
	var snapshot := get_egg_snapshot()
	egg_updated.emit(snapshot)
	egg_hatched.emit(snapshot)


func _emit_update() -> void:
	egg_updated.emit(get_egg_snapshot())


func _get_progress_ratio() -> float:
	if hatch_duration_seconds <= 0.0:
		return 1.0
	return clampf(1.0 - (time_remaining_seconds / hatch_duration_seconds), 0.0, 1.0)


func _on_update_timer_timeout() -> void:
	if is_hatched:
		return

	_sync_time_remaining()
	if is_equal_approx(time_remaining_seconds, 0.0):
		_finish_hatching()
		return

	_emit_update()


func _sync_time_remaining() -> void:
	if is_hatched:
		time_remaining_seconds = 0.0
		return

	var now_msec := Time.get_ticks_msec()
	time_remaining_seconds = maxf(0.0, float(_hatch_deadline_msec - now_msec) / 1000.0)


func _refresh_deadline_from_remaining() -> void:
	_hatch_deadline_msec = Time.get_ticks_msec() + int(round(time_remaining_seconds * 1000.0))
