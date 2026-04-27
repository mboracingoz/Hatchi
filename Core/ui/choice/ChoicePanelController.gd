extends PanelContainer
class_name ChoicePanelController

@export var question_label: Label
@export var option_a_button: Button
@export var option_b_button: Button

func _ready() -> void:
	visible = false

func show_choice(_event_id: StringName) -> void:
	var parent_node := get_parent()
	while parent_node != null and parent_node is CanvasItem:
		parent_node.visible = true
		parent_node = parent_node.get_parent()

	visible = true
	show()
	modulate.a = 1.0

	if question_label != null:
		question_label.text = "What should we do?"

	if option_a_button != null:
		option_a_button.text = "Play"

	if option_b_button != null:
		option_b_button.text = "Rest"
