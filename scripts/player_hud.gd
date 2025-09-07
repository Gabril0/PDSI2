extends CanvasLayer

const InventorySlotScene = preload("res://scenes/ui/InventorySlot.tscn")

@onready var money_label: Label = $MarginContainer/HBoxContainer/MoneyLabel
@onready var item_container: HBoxContainer = $MarginContainer2/VBoxContainer/ItemContainer

func _ready():
	PlayerData.coins_updated.connect(_on_coins_updated)
	PlayerData.inventory_updated.connect(_on_inventory_updated)
	
	_on_coins_updated(PlayerData.coins)
	_on_inventory_updated(PlayerData.inventory)


func _on_coins_updated(new_amount: int):
	money_label.text = "%d" % new_amount
	

func _on_inventory_updated(new_inventory: Dictionary):
	for child in item_container.get_children():
		child.queue_free()
		
	for item in new_inventory:
		var quantity = new_inventory[item]
		
		var slot_instance = InventorySlotScene.instantiate()
		item_container.add_child(slot_instance)
		slot_instance.update_display(item, quantity)
