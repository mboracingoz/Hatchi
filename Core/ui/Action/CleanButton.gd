extends Button

@onready var need_system = get_tree().get_first_node_in_group("need_system")
@onready var pet_state_controller = get_tree().get_first_node_in_group("pet_state_controller")

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if need_system == null:
		return
	
	if pet_state_controller != null:
		pet_state_controller.play_action_reaction(1.07)
	
	var hygiene = need_system.needs.get("hygiene")
	if hygiene == null:
		return

	hygiene.increase(25.0)
	print("Clean button pressed")
