# Esse script vai gerenciar os dados globais do jogador, como o dinheiro e inventário.
# Depois conversar com o Crepaldi para ver se já não tem outra implementação que faça isso.
# O objetivo dessa parte é criar um script que está sempre acessível de qualquer lugar do código, 
# sem a necessidade de obter referências diretas a nós específicos como o Player

extends Node

signal coins_updated(new_amout: int) #Vei ser emitido sempre que a quant de moedas mudar

signal inventory_updated(new_inventory: Dictionary)

var coins: int = 50

var inventory: Dictionary = {}

var cause_of_death_info: Dictionary = {}

func can_afford(amount: int) -> bool:
	return coins >= amount

func add_money(amount: int) -> void:
	coins += amount
	coins_updated.emit(coins)
	print("Moeda adicionada, Total: ", coins)

func remove_money(amount: int) -> void:
	if can_afford(amount):
		coins -= amount
		coins_updated.emit(coins)
		print("Moedas debitadas. Total agora: ", coins)
		
func add_item(item_resource: Item) -> void:
	if inventory.has(item_resource):
		inventory[item_resource] += 1
	else:
		inventory[item_resource] = 1
	
	print("Item ", item_resource.i_name, "adicionado ao inventario")
	inventory_updated.emit(inventory)

func set_cause_of_death(attacker_node: Node2D):
	# Limpa a informação anterior
	cause_of_death_info.clear()

	# Tenta pegar uma textura de retrato do inimigo (precisaremos adicionar isso no inimigo)
	if attacker_node and attacker_node.has_method("get_portrait_texture"):
		cause_of_death_info["portrait"] = attacker_node.get_portrait_texture()
	else:
		cause_of_death_info["portrait"] = null # Sem imagem

	cause_of_death_info["name"] = attacker_node.name if attacker_node else "Ambiente"

##Esse script vai ser um autoload
