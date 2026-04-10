extends Button

@onready var need_system = get_tree().get_first_node_in_group("need_system")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if need_system == null:
		return
	
	
	need_system.feed(20.0)
	print("Feed pressed")
