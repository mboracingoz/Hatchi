extends Button

@onready var pet_state_controller = get_tree().get_first_node_in_group("pet_state_controller")

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if pet_state_controller != null:
		pet_state_controller.play_action_reaction(1.04)

	print("Sleep button pressed")
