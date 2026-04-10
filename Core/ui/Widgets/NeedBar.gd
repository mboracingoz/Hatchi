extends ProgressBar

@export var need_id: String = ""

@onready var need_system = get_tree().get_first_node_in_group("need_system")

func _ready() -> void:
	min_value = 0
	max_value = 100

	if need_system == null:
		push_warning("NeedSystem not found.")
		return

	await need_system.ready


func _process(_delta: float) -> void:
	if need_system == null:
		return

	var stat = need_system.needs.get(need_id)

	if stat != null:
		value = stat.current_value	
