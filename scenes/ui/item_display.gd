extends PanelContainer

signal item_purchased(item_data: Item)

@onready var item_texture: TextureRect = $VBoxContainer/ItemTexture
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var price_label: Label = $VBoxContainer/PriceLabel
@onready var buybutton: Button = $VBoxContainer/BuyButton

var current_item_data: Item

func setup(item_resource: Item) -> void:
	current_item_data = item_resource
	item_texture.texture = current_item_data.icon
	name_label.text = current_item_data.i_name
	price_label.text = "%d Moedas" % current_item_data.price
	

func _on_buy_button_pressed() -> void:
	if current_item_data: #Verifica se o item eh valido
		emit_signal("item_purchased", current_item_data)
