extends Button

@onready var need_system = get_tree().get_first_node_in_group("need_system")
@onready var pet_state_controller = get_tree().get_first_node_in_group("pet_state_controller")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	need_system.feed(20.0)

	if pet_state_controller != null:
		pet_state_controller.play_action_reaction(1.12)

	print("Feed pressed")
