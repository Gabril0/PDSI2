# GameOverScreen.gd
extends Control

# Caminhos para os nós que vamos preencher. Ajuste se sua hierarquia for diferente.
@onready var item_grid: GridContainer = $HBoxContainer/PanelContainer/VBoxContainer/ItemGrid
@onready var enemy_portrait: TextureRect = $HBoxContainer/PanelContainer/VBoxContainer/EnemyPortrait
@onready var btn_tentar_novamente: Button = $HBoxContainer/PanelContainer/VBoxContainer/VBoxContainer/BtnTentarNovamente
@onready var btn_sair: Button = $HBoxContainer/PanelContainer/VBoxContainer/VBoxContainer/BtnSair

func _ready():
	
	print("--- TELA GAME OVER CARREGADA ---")
	print("Inventário visto pela tela: ", PlayerData.inventory)
	print("Causa da morte vista pela tela: ", PlayerData.cause_of_death_info)
	
	_populate_items()
	_show_cause_of_death()
	
	btn_tentar_novamente.pressed.connect(_on_tentar_novamente_pressed)
	btn_sair.pressed.connect(_on_sair_pressed)

func _populate_items():
	# Lê o inventário do nosso Singleton
	var inventory = PlayerData.inventory
	for item_resource in inventory:
		var quantity = inventory[item_resource]
		
		# Cria um slot para cada item
		var slot = Control.new()
		slot.custom_minimum_size = Vector2(48, 48)
		
		var icon = TextureRect.new()
		icon.texture = item_resource.icon
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		slot.add_child(icon)
		
		# Se tiver mais de um, adiciona o contador
		if quantity > 1:
			var label = Label.new()
			label.text = "x%d" % quantity
			# Posiciona o label no canto inferior direito
			label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
			slot.add_child(label)
			
		item_grid.add_child(slot)

func _show_cause_of_death():
	var cause_info = PlayerData.cause_of_death_info
	if cause_info.has("portrait") and cause_info["portrait"] != null:
		enemy_portrait.texture = cause_info["portrait"]

func _on_tentar_novamente_pressed():
	# Reinicia a run. A forma mais simples é recarregar a cena do jogo.
	get_tree().change_scene_to_file("res://Mundo.tscn")

func _on_sair_pressed():
	# Volta para o menu principal
	get_tree().change_scene_to_file("res://MainMenu.tscn")
