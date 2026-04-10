extends Button

@onready var need_system = get_tree().get_first_node_in_group("need_system")

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if need_system == null:
		return

	var hygiene = need_system.needs.get("hygiene")
	if hygiene == null:
		return

	hygiene.increase(25.0)
	print("Clean button pressed")
