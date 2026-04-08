extends ProgressBar

@onready var need_system = get_tree().get_first_node_in_group("need_system")

func _ready() -> void:
	print("HungerBar _ready")

	min_value = 0
	max_value = 100

	if need_system == null:
		push_warning("NeedSystem not found.")
		return

	print("NeedSystem found: ", need_system.name)

	need_system.hunger_changed.connect(_on_hunger_changed)
	value = need_system.hunger.current_value
	print("Initial bar value: ", value)

func _on_hunger_changed(new_value: float) -> void:
	value = new_value
	print("UI UPDATE: ", new_value)
