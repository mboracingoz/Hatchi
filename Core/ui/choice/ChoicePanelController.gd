extends PanelContainer
class_name ChoicePanelController

signal choice_selected(event_id: StringName, option_id: StringName)

@export var question_label: Label
@export var option_a_button: Button
@export var option_b_button: Button

var current_event_id: StringName

func _ready() -> void:
	hide()

	if option_a_button != null:
		option_a_button.pressed.connect(_on_option_a_pressed)

	if option_b_button != null:
		option_b_button.pressed.connect(_on_option_b_pressed)


func show_choice(event_id: StringName) -> void:
	current_event_id = event_id

	var parent_node := get_parent()
	while parent_node != null and parent_node is CanvasItem:
		parent_node.visible = true
		parent_node = parent_node.get_parent()

	show()
	modulate.a = 1.0

	if question_label != null:
		question_label.text = "What should we do?"

	if option_a_button != null:
		option_a_button.text = "Play"

	if option_b_button != null:
		option_b_button.text = "Rest"


func _on_option_a_pressed() -> void:
	choice_selected.emit(current_event_id, &"option_a")
	hide()


func _on_option_b_pressed() -> void:
	choice_selected.emit(current_event_id, &"option_b")
	hide()
