#Responsabilidades dessa parte é: 
# - Mostrar itens na venda
# - Criar instancia de itemDisplay para cada item
# - Adicionar as instâncias no grid container
# - Ouvir o sinal item_purchased de cada item para saber quando o jogador tenta fazer a compra

extends Control

const ItemDisplaysScene = preload("res://scenes/ui/ItemDisplay.tscn")

@onready var grid_container: GridContainer = $Panel/CenterContainer/GridContainer


@export_group("Pool de Itens por Nível")
@export var level_0_items: Array[Item]
@export var level_1_items: Array[Item]
@export var level_2_items: Array[Item]
@export var level_3_items: Array[Item]
@export var level_4_items: Array[Item]
@export var level_5_items: Array[Item]

func _ready() -> void:
	populate_shop()
	

func populate_shop() -> void:
	var current_level = LevelManager.level_number
	
	var item_pool: Array[Item] = []
	match current_level:
		0:
			item_pool = level_0_items
		1:
			item_pool = level_1_items
		2:
			item_pool = level_2_items
		3:
			item_pool = level_3_items
		4:
			item_pool = level_4_items
		5:
			item_pool = level_5_items
	
	#Limpando a loja anterior
	for child in grid_container.get_children():
		child.queue_free()
	
	for item_resource in item_pool:
		var item_display = ItemDisplaysScene.instantiate()
		grid_container.add_child(item_display)
		item_display.setup(item_resource)
		item_display.item_purchased.connect(_on_item_purchased)
		
func _on_item_purchased(item_data: Item) -> void:
	var price = item_data.price
	
	if PlayerData.can_afford(price):
		PlayerData.remove_money(price)
		PlayerData.add_item(item_data)
		print("Compra de ", item_data.i_name)
	else:
		print("Sem moedas suficiente.")
		
