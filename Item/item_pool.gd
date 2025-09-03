extends Node

@export var tier1_items : Array[PackedScene]
@export var tier2_items : Array[PackedScene]
@export var tier3_items : Array[PackedScene]
@export var tier4_items : Array[PackedScene]
@export var tier5_items : Array[PackedScene]

func get_random_from_tier(tier: int) -> Item:
	var items: Array[PackedScene] = []
	match tier:
		1: items = tier1_items
		2: items = tier2_items
		3: items = tier3_items
		4: items = tier4_items
		5: items = tier5_items
		_: return null
	
	if items.is_empty():
		return null

	var packed: PackedScene = items[randi_range(0, items.size() - 1)]

	var inst = packed.instantiate()

	var item: Item = inst as Item
	return item
