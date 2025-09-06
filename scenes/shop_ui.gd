#Responsabilidades dessa parte é: 
# - Mostrar itens na venda
# - Criar instancia de itemDisplay para cada item
# - Adicionar as instâncias no grid container
# - Ouvir o sinal item_purchased de cada item para saber quando o jogador tenta fazer a compra

extends Control

const ItemDisplaysScene = preload("res://scenes/ui/ItemDisplay.tscn")

@onready var grid_container: GridContainer = $Panel/GridContainer

@export var items_for_sale: Array[Item]

func _ready() -> void:
	populate_shop()
	

func populate_shop() -> void:
	
	for item_resource in items_for_sale:
		var item_display = ItemDisplaysScene.instantiate()
		grid_container.add_child(item_display)
		item_display.setup(item_resource)
		item_display.item_purchased.connect(_on_item_purchased)
		
func _on_item_purchased(item_data: Item) -> void:
	print("Tentativa de compra do item: '", item_data.i_name, "' por ", item_data.price, " moedas.")
