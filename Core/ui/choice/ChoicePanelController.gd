extends PanelContainer
class_name ChoicePanelController

signal choice_selected(event_id: StringName, option_id: StringName)

@export var question_label: Label
@export var option_a_button: Button
@export var option_b_button: Button

var current_event_id: StringName
var current_event_data: Dictionary = {}

func _ready() -> void:
	hide()

	if option_a_button != null:
		option_a_button.pressed.connect(_on_option_a_pressed)

	if option_b_button != null:
		option_b_button.pressed.connect(_on_option_b_pressed)


func show_choice(event_data: Dictionary) -> void:
	current_event_data = event_data.duplicate(true)
	current_event_id = StringName(current_event_data.get("id", &""))

	var parent_node := get_parent()
	while parent_node != null and parent_node is CanvasItem:
		parent_node.visible = true
		parent_node = parent_node.get_parent()

	show()
	modulate.a = 1.0

	if question_label != null:
		question_label.text = str(current_event_data.get("question", "What should we do?"))

	var options: Array = current_event_data.get("options", [])
	var option_a: Dictionary = options[0] if options.size() > 0 else {}
	var option_b: Dictionary = options[1] if options.size() > 1 else {}

	if option_a_button != null:
		option_a_button.text = str(option_a.get("text", "Option A"))
		option_a_button.disabled = option_a.is_empty()

	if option_b_button != null:
		option_b_button.text = str(option_b.get("text", "Option B"))
		option_b_button.disabled = option_b.is_empty()


func _on_option_a_pressed() -> void:
	_emit_choice_at_index(0)


func _on_option_b_pressed() -> void:
	_emit_choice_at_index(1)

func _emit_choice_at_index(index: int) -> void:
	var options: Array = current_event_data.get("options", [])
	if index < 0 or index >= options.size():
		return

	var option_id := StringName(options[index].get("id", &""))
	choice_selected.emit(current_event_id, option_id)
	hide()
