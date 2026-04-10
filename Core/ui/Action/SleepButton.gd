extends Button

@onready var need_system = get_tree().get_first_node_in_group("need_system")

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if need_system == null:
		return

	var sleep_stat = need_system.needs.get("sleep")
	if sleep_stat == null:
		return

	sleep_stat.increase(20.0)
	print("Sleep button pressed")
