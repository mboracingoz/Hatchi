extends Button

@onready var need_system = get_tree().get_first_node_in_group("need_system")
@onready var pet_state_controller = get_tree().get_first_node_in_group("pet_state_controller")
@onready var personality_system = get_tree().get_first_node_in_group("personality_system")
@onready var bond_system = get_tree().get_first_node_in_group("bond_system")
@onready var lifecycle_system = get_tree().get_first_node_in_group("lifecycle_system")

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if need_system == null:
		return
	
	if pet_state_controller != null:
		pet_state_controller.play_action_reaction(1.07)

	if need_system.has_method("add_hygiene"):
		need_system.add_hygiene(25.0)

	if personality_system != null and personality_system.has_method("record_care_action"):
		personality_system.record_care_action(&"clean")

	if bond_system != null and bond_system.has_method("record_care_action"):
		bond_system.record_care_action(&"clean")

	if lifecycle_system != null and lifecycle_system.has_method("record_care_action"):
		lifecycle_system.record_care_action(&"clean")
	print("Clean button pressed")
