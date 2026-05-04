extends PanelContainer
class_name EggPanelController

@export var title_label: Label
@export var status_label: Label
@export var hint_label: Label
@export var crack_button: Button
@export var egg_visual_root: Control
@export var egg_shell: Control
@export var crack_small_label: Label
@export var crack_large_label: Label
@export var hatch_burst_label: Label

@export var need_panel: CanvasItem
@export var action_panel: CanvasItem
@export var bottom_nav: CanvasItem
@export var pet_visual: CanvasItem
@export var state_label: CanvasItem
@export var idle_event_ui: CanvasItem
@export var sleep_warning_label: CanvasItem
@export var choice_overlay_root: CanvasItem
@export var pet_area_placeholder_label: CanvasItem

@export var egg_system: Node

var _egg_tween: Tween

func _ready() -> void:
	if crack_button != null:
		crack_button.pressed.connect(_on_crack_pressed)

	if egg_system != null and egg_system.has_signal("egg_updated"):
		if not egg_system.egg_updated.is_connected(_on_egg_updated):
			egg_system.egg_updated.connect(_on_egg_updated)

	if egg_system != null and egg_system.has_signal("egg_hatched"):
		if not egg_system.egg_hatched.is_connected(_on_egg_hatched):
			egg_system.egg_hatched.connect(_on_egg_hatched)

	if egg_system != null and egg_system.has_method("get_egg_snapshot"):
		_on_egg_updated(egg_system.get_egg_snapshot())


func _on_crack_pressed() -> void:
	if egg_system == null or not egg_system.has_method("tap_egg"):
		return

	egg_system.tap_egg()
	_play_crack_feedback()


func _on_egg_updated(snapshot: Dictionary) -> void:
	var is_hatched := bool(snapshot.get("is_hatched", false))
	visible = not is_hatched
	_set_gameplay_visible(is_hatched)

	if title_label != null:
		title_label.text = "%s Egg" % _capitalize(str(snapshot.get("rarity_tier", "common")))

	if status_label != null:
		var remaining := float(snapshot.get("time_remaining_seconds", 0.0))
		var cracks := int(snapshot.get("crack_count", 0))
		status_label.text = "Ready in %ss | Cracks: %d" % [int(ceil(remaining)), cracks]

	if hint_label != null:
		var used := float(snapshot.get("tap_acceleration_used", 0.0))
		var limit := float(snapshot.get("tap_acceleration_limit", 0.0))
		hint_label.text = "Tap to help crack it. Bonus used: %.0f / %.0fs" % [used, limit]

	if crack_button != null:
		crack_button.disabled = is_hatched

	_update_egg_visual(snapshot)


func _on_egg_hatched(_snapshot: Dictionary) -> void:
	_set_gameplay_visible(true)
	_play_hatch_feedback()


func _set_gameplay_visible(is_visible: bool) -> void:
	for node in [
		need_panel,
		action_panel,
		bottom_nav,
		pet_visual,
		state_label,
		idle_event_ui,
		sleep_warning_label,
		choice_overlay_root,
		pet_area_placeholder_label,
	]:
		if node != null:
			node.visible = is_visible


func get_egg_visibility_snapshot() -> Dictionary:
	return {
		"egg_panel": visible,
		"pet_visual": _get_node_visible(pet_visual),
		"need_panel": _get_node_visible(need_panel),
		"action_panel": _get_node_visible(action_panel),
		"bottom_nav": _get_node_visible(bottom_nav),
		"idle_event_ui": _get_node_visible(idle_event_ui),
		"sleep_warning_label": _get_node_visible(sleep_warning_label),
		"overlay_root": _get_node_visible(choice_overlay_root),
		"pet_area_placeholder_label": _get_node_visible(pet_area_placeholder_label),
	}


func _capitalize(text: String) -> String:
	if text.is_empty():
		return text
	return text.substr(0, 1).to_upper() + text.substr(1)


func _get_node_visible(node: CanvasItem) -> bool:
	if node == null:
		return false
	return node.visible


func _update_egg_visual(snapshot: Dictionary) -> void:
	var cracks := int(snapshot.get("crack_count", 0))
	var progress := float(snapshot.get("progress_ratio", 0.0))

	if crack_small_label != null:
		crack_small_label.visible = cracks >= 1 or progress >= 0.18

	if crack_large_label != null:
		crack_large_label.visible = cracks >= 3 or progress >= 0.45

	if egg_shell != null:
		var tint: float = 1.0 - minf(progress, 0.75) * 0.18
		egg_shell.modulate = Color(1.0, tint, tint * 0.94, 1.0)


func _play_crack_feedback() -> void:
	if egg_visual_root == null:
		return

	if _egg_tween != null:
		_egg_tween.kill()

	egg_visual_root.rotation_degrees = 0.0
	egg_visual_root.scale = Vector2.ONE
	_egg_tween = create_tween()
	_egg_tween.set_trans(Tween.TRANS_BACK)
	_egg_tween.set_ease(Tween.EASE_OUT)
	_egg_tween.tween_property(egg_visual_root, "rotation_degrees", -8.0, 0.06)
	_egg_tween.tween_property(egg_visual_root, "rotation_degrees", 10.0, 0.08)
	_egg_tween.tween_property(egg_visual_root, "rotation_degrees", 0.0, 0.08)
	_egg_tween.parallel().tween_property(egg_visual_root, "scale", Vector2(1.07, 0.96), 0.08)
	_egg_tween.tween_property(egg_visual_root, "scale", Vector2.ONE, 0.10)


func _play_hatch_feedback() -> void:
	if crack_button != null:
		crack_button.disabled = true

	if hatch_burst_label != null:
		hatch_burst_label.visible = true
		hatch_burst_label.modulate.a = 1.0
		hatch_burst_label.scale = Vector2(0.7, 0.7)

	if _egg_tween != null:
		_egg_tween.kill()

	_egg_tween = create_tween()
	_egg_tween.set_parallel(true)
	if egg_visual_root != null:
		_egg_tween.tween_property(egg_visual_root, "scale", Vector2(1.26, 1.26), 0.18)
		_egg_tween.tween_property(egg_visual_root, "modulate:a", 0.0, 0.20)
	if hatch_burst_label != null:
		_egg_tween.tween_property(hatch_burst_label, "scale", Vector2(1.22, 1.22), 0.18)
		_egg_tween.tween_property(hatch_burst_label, "modulate:a", 0.0, 0.22)
	_egg_tween.set_parallel(false)
	_egg_tween.tween_callback(func() -> void:
		visible = false
		if egg_visual_root != null:
			egg_visual_root.modulate.a = 1.0
			egg_visual_root.scale = Vector2.ONE
		if hatch_burst_label != null:
			hatch_burst_label.visible = false
			hatch_burst_label.modulate.a = 1.0
			hatch_burst_label.scale = Vector2.ONE
	)
