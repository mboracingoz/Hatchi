extends Button

@onready var need_system = get_tree().get_first_node_in_group("need_system")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if need_system == null:
		return
	
	var happiness = need_system.needs.get("happiness")
	if happiness != null:
		happiness.increase(100.0)
	
	print("Cuddle button pressed")
	
