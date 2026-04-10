extends Node

signal hunger_changed(value: float)

var needs = {}

func _ready() -> void:
	var hunger = NeedStat.new()
	hunger.id = &"hunger"
	hunger.max_value = 100.0
	hunger.current_value = 70.0
	hunger.decay_per_second = 1.0

	needs["hunger"] = hunger
	
	var happiness = NeedStat.new()
	happiness.id = &"happiness"
	happiness.max_value = 100.0
	happiness.current_value = 80.0
	happiness.decay_per_second = 0.5
	
	needs["happiness"] = happiness
	
	var hygiene = NeedStat.new()
	hygiene.id = &"hygiene"
	hygiene.max_value = 100.0
	hygiene.current_value = 90.0
	hygiene.decay_per_second = 0.3
	
	needs["hygiene"] = hygiene
	
	var sleep = NeedStat.new()
	sleep.id = &"sleep"
	sleep.max_value = 100.0
	sleep.current_value = 75.0
	sleep.decay_per_second = 0.2
	
	needs["sleep"] = sleep
	
	_emit_hunger_changed()

func _process(delta: float) -> void:
		for key in needs.keys():
			var stat: NeedStat = needs[key]
			
			if stat == null:
				continue
			
			stat.decrease(delta)
	
		_emit_hunger_changed()

func feed(amount: float) -> void:
	var hunger: NeedStat = needs.get("hunger")

	if hunger == null:
		return

	hunger.increase(amount)
	_emit_hunger_changed()

func _emit_hunger_changed() -> void:
	var hunger: NeedStat = needs.get("hunger")

	if hunger == null:
		return

	hunger_changed.emit(hunger.current_value)
