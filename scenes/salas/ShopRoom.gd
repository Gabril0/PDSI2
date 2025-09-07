extends Node2D

#Pré-Carrega a cena na UI da Loja
const ShopUIScene = preload("res://scenes/ui/ShopUI.tscn")

var shop_instance = null

func _on_player_detector_body_entered(body):
	if not body.is_in_group("player"):
		return
		
	if shop_instance == null:
		print("Jogador entrou na loja. Instanciando UI...")
		shop_instance = ShopUIScene.instantiate()
		
		# Procura o nosso UILayer na cena principal e adiciona a loja como filha
		get_tree().root.get_node("Mundo/UILayer").add_child(shop_instance)

func _on_player_detector_body_exited(body):
	if not body.is_in_group("player"):
		return
	
	if is_instance_valid(shop_instance):
		print("Jogador saiu da loja. Removendo UI.")
		shop_instance.queue_free()
		shop_instance = null
