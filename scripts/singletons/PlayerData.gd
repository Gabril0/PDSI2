# Esse script vai gerenciar os dados globais do jogador, como o dinheiro e inventário.
# Depois conversar com o Crepaldi para ver se já não tem outra implementação que faça isso.
# O objetivo dessa parte é criar um script que está sempre acessível de qualquer lugar do código, 
# sem a necessidade de obter referências diretas a nós específicos como o Player

extends Node

signal coins_updated(new_amout: int) #Vei ser emitido sempre que a quant de moedas mudar

var coins: int = 10

var inventory: Array[Item] #guardar os itens

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
	inventory.append(item_resource)
	print("Item ", item_resource.i_name, "adicionado ao inventario")

##Esse script vai ser um autoload
