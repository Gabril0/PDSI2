extends Control

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel


func update_display(item_resource: Item, quantity: int):
	icon.texture = item_resource.icon

	if quantity > 1:
		quantity_label.text = "x%d" % quantity
		quantity_label.show()
	else:
		quantity_label.hide()
